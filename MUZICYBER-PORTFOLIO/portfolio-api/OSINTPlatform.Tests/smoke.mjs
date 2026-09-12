// Run with the development API already listening on localhost:5240.
import { strict as assert } from 'node:assert';
import { randomBytes, createHash } from 'node:crypto';
import { mkdir, writeFile, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const base=process.env.API_BASE_URL || 'http://localhost:5240';
const suffix=Date.now().toString(36),password=randomBytes(24).toString('base64url');
let checks=0;
async function req(method,url,token,body,expected=200) {
 const r=await fetch(base+url,{method,headers:{...(token ? {Authorization:'Bearer '+token} : {}),...(body ? {'Content-Type':'application/json'} : {})},body:body ? JSON.stringify(body) : undefined});
 const text=await r.text();assert.equal(r.status,expected,method+' '+url+': '+text);checks++;
 return text ? JSON.parse(text) : null;
}
await req('GET','/api/cases',null,null,401);
const a=await req('POST','/api/auth/register',null,{username:'preview_'+suffix,password});
const b=await req('POST','/api/auth/register',null,{username:'other_'+suffix,password});
await req('POST','/api/auth/login',null,{username:a.username,password:'incorrect-passphrase'},401);
await req('POST','/api/auth/login',null,{username:a.username,password});
await req('POST','/api/cases',a.token,{title:'Bad case',status:'invalid',priority:'Normal'},400);
const c=await req('POST','/api/cases',a.token,{title:'Public infrastructure review',description:'DEMONSTRATION CASE — public example inputs only. Review domains and research leads.',priority:'High'},201);
assert.equal((await req('GET','/api/cases',b.token)).length,0);
await req('GET','/api/cases/'+c.id,b.token,null,404);
await req('PUT','/api/cases/'+c.id,a.token,{title:c.title,description:c.description,status:'In progress',priority:'High'});
await req('POST','/api/osint/phone',a.token,{caseId:c.id,value:'invalid'},400);
await req('POST','/api/osint/phone',b.token,{caseId:c.id,value:'+923001234567'},404);
for(const [type,value] of [['phone','+923001234567'],['email','review@example.com'],['username','example'],['ip','8.8.8.8'],['domain','example.com']]) {
 const result=await req('POST','/api/osint/'+type,a.token,{caseId:c.id,value});assert.ok(result.findings.length>0);
}
const graph=await req('GET','/api/correlation/'+c.id,a.token);assert.equal(graph.nodes.length,5);
await req('GET','/api/correlation/'+c.id,b.token,null,404);
assert.equal((await req('POST','/api/forensics/cnic',a.token,{value:'35202-1234567-1'})).valid,true);
assert.equal((await req('POST','/api/forensics/cnic',a.token,{value:'invalid'})).valid,false);
async function upload(name,bytes,token,endpoint='/api/evidence',expected=200) {
 const form=new FormData();form.append('caseId',c.id);form.append('source','Synthetic test fixture; not real investigation evidence');form.append('file',new Blob([bytes]),name);
 const r=await fetch(base+endpoint,{method:'POST',headers:{Authorization:'Bearer '+token},body:form});
 const text=await r.text();assert.equal(r.status,expected,text);checks++;return JSON.parse(text);
}
const bytes=Buffer.from('Synthetic evidence for integrity testing.\n');
const e=await upload('review-note.txt',bytes,a.token);
assert.equal(e.sha256,createHash('sha256').update(bytes).digest('hex'));
await upload('spoof.png',bytes,a.token,'/api/forensics/image',400);
await upload('review-note.txt',bytes,b.token,'/api/evidence',404);
const png=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1sAAAAASUVORK5CYII=','base64');
const image=await upload('pixel.png',png,a.token,'/api/forensics/image');
const metadata=JSON.parse(image.metadata);assert.equal(metadata.width,1);assert.equal(metadata.height,1);assert.ok(metadata.metadataStatus);
await req('GET','/api/evidence/'+c.id,b.token,null,404);
await req('GET','/api/evidence/'+c.id+'/'+e.id,b.token,null,404);
const original=await fetch(base+'/api/evidence/'+c.id+'/'+e.id,{headers:{Authorization:'Bearer '+a.token}});
assert.equal(original.status,200);assert.deepEqual(Buffer.from(await original.arrayBuffer()),bytes);checks++;
const stored=path.join(root,'evidence','documents',e.id.replaceAll('-','')+'.bin');
try {
 await writeFile(stored,'tampered synthetic evidence');
 assert.equal((await req('POST','/api/evidence/'+c.id+'/'+e.id+'/verify',a.token)).integrityStatus,'Mismatch');
 await req('GET','/api/evidence/'+c.id+'/'+e.id,a.token,null,409);
} finally { await writeFile(stored,bytes); }
assert.equal((await req('POST','/api/evidence/'+c.id+'/'+e.id+'/verify',a.token)).integrityStatus,'Verified');
await req('DELETE','/api/cases/'+c.id,a.token,null,409);
const report=await req('POST','/api/reports/'+c.id,a.token);
await req('GET','/api/reports/'+report.id,b.token,null,404);
const pdfResponse=await fetch(base+'/api/reports/'+report.id,{headers:{Authorization:'Bearer '+a.token}});
assert.equal(pdfResponse.status,200);const pdf=Buffer.from(await pdfResponse.arrayBuffer());assert.equal(pdf.subarray(0,8).toString(),'%PDF-1.4');checks++;
await mkdir(path.join(root,'tmp'),{recursive:true});await writeFile(path.join(root,'tmp','smoke-report.pdf'),pdf);
const empty=await req('POST','/api/cases',a.token,{title:'Empty case for deletion'},201);
await req('DELETE','/api/cases/'+empty.id,a.token,null,204);
await req('GET','/api/cases/'+empty.id,a.token,null,404);
await req('POST','/api/cases',a.token,{title:'Suspicious email triage',description:'DEMONSTRATION CASE — awaiting source collection.',priority:'Normal'},201);
const done=await req('POST','/api/cases',a.token,{title:'Image evidence review',description:'DEMONSTRATION CASE — completed training example.',priority:'Normal',status:'Closed'},201);
await writeFile(path.join(root,'tmp','preview-session.json'),JSON.stringify({username:a.username,password,caseId:c.id,closedCaseId:done.id},null,2));
console.log(JSON.stringify({result:'PASS',checks,report:'tmp/smoke-report.pdf',previewSession:'tmp/preview-session.json'}));
