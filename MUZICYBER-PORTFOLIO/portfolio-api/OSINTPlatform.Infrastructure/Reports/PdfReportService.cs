using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using OSINTPlatform.Core;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
namespace OSINTPlatform.Infrastructure.Reports;
public sealed class PdfReportService(ApplicationDbContext db,ICaseService cases,IEvidenceService evidence,IConfiguration config) : IReportService
{
 public async Task<Report> GenerateAsync(Guid caseId,Guid userId,CancellationToken ct)
 {
  var c=await cases.GetAsync(caseId,userId,ct);
  var findings=await db.Findings.AsNoTracking().Where(f=>db.Investigations.Any(i=>i.Id==f.InvestigationId && i.CaseId==caseId)).OrderBy(x=>x.CreatedAt).ToListAsync(ct);
  var records=await evidence.ListAsync(caseId,userId,ct);
  var lines=new List<string> { "SENTINEL / INVESTIGATION REPORT", c.CaseNumber, c.Title, $"Status: {c.Status} | Priority: {c.Priority}", $"Generated (UTC): {DateTimeOffset.UtcNow:O}", "", "CASE SUMMARY",c.Description,"","FINDINGS" };
  foreach(var f in findings) { lines.Add($"{f.FindingType}: {f.Value}"); lines.Add($"Source: {(f.SourceUrl.Length==0 ? "Local validation / DNS" : f.SourceUrl)} | Confidence: {f.Confidence:P0}"); }
  if(findings.Count==0) lines.Add("No findings recorded.");
  lines.Add("");lines.Add("EVIDENCE / SHA-256");
  foreach(var item in records) { var e=await evidence.VerifyAsync(caseId,item.Id,userId,ct); lines.Add(e.OriginalName);lines.Add($"Source: {e.Source}");lines.Add($"SHA-256: {e.Sha256}");lines.Add($"Integrity: {e.IntegrityStatus} | Collected: {e.CollectedAt:O}"); }
  if(records.Count==0) lines.Add("No evidence recorded.");
  lines.Add("");lines.Add("LIMITATIONS");lines.Add("Public-source URLs are leads, not verified accounts. Format validation does not establish identity. Hash verification establishes byte consistency, not authenticity. EXIF can be edited; OCR requires a configured local engine. See evidence metadata for extraction status. This PDF uses ASCII text; original Unicode values remain in the database and app.");
  var report=new Report { CaseId=caseId };
  var dir=Path.Combine(config["Storage:Root"]!,"reports","generated");Directory.CreateDirectory(dir);
  report.ReportPath=Path.Combine(dir,report.Id.ToString("N")+".pdf");
  await File.WriteAllBytesAsync(report.ReportPath,Render(lines),ct);
  try { db.Reports.Add(report);await db.SaveChangesAsync(ct); } catch { File.Delete(report.ReportPath);throw; }
  return report;
 }
 public async Task<byte[]> DownloadAsync(Guid id,Guid userId,CancellationToken ct) {
  var r=await db.Reports.SingleOrDefaultAsync(x=>x.Id==id,ct) ?? throw new MissingException();
  await cases.GetAsync(r.CaseId,userId,ct);
  if(!File.Exists(r.ReportPath)) throw new MissingException("Report file is missing.");
  return await File.ReadAllBytesAsync(r.ReportPath,ct);
 }
 public static byte[] Render(IEnumerable<string> lines)
 {
  var wrapped=lines.SelectMany(l=> {
   var ascii=new string(l.Select(ch=>ch is >= ' ' and <= '~' ? ch : ' ').ToArray());
   return ascii.Length==0 ? new[]{""} : Enumerable.Range(0,(ascii.Length+87)/88).Select(i=>ascii.Substring(i*88,Math.Min(88,ascii.Length-i*88)));
  }).ToArray();
  var pages=wrapped.Chunk(46).ToArray(); if(pages.Length==0) pages=[[""]];
  var objects=new List<string>{"<< /Type /Catalog /Pages 2 0 R >>","", "<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>"};
  var ids=new List<int>();
  for(int i=0;i<pages.Length;i++) {
   int pageId=objects.Count+1, streamId=pageId+1;ids.Add(pageId);
   objects.Add($"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents {streamId} 0 R >>");
   var content=new StringBuilder("BT /F1 9 Tf 42 790 Td 15 TL\n");
   foreach(var line in pages[i]) content.Append('(').Append(line.Replace("\\","\\\\").Replace("(","\\(").Replace(")","\\)")).Append(") Tj T*\n");
   content.Append($"(Page {i+1} / {pages.Length}) Tj\nET");
   var stream=content.ToString();objects.Add($"<< /Length {Encoding.ASCII.GetByteCount(stream)} >>\nstream\n{stream}\nendstream");
  }
  objects[1]=$"<< /Type /Pages /Kids [{string.Join(" ",ids.Select(i=>$"{i} 0 R"))}] /Count {pages.Length} >>";
  var pdf=new StringBuilder("%PDF-1.4\n");var offsets=new List<int>{0};
  for(int i=0;i<objects.Count;i++) { offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));pdf.Append($"{i+1} 0 obj\n{objects[i]}\nendobj\n"); }
  var xref=Encoding.ASCII.GetByteCount(pdf.ToString());pdf.Append($"xref\n0 {objects.Count+1}\n0000000000 65535 f \n");
  foreach(var offset in offsets.Skip(1)) pdf.Append($"{offset:D10} 00000 n \n");
  pdf.Append($"trailer\n<< /Size {objects.Count+1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n");
  return Encoding.ASCII.GetBytes(pdf.ToString());
 }
}
