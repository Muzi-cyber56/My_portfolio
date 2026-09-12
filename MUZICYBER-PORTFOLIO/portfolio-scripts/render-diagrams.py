from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math
root=Path(__file__).resolve().parents[1]/"docs"/"diagrams"
root.mkdir(parents=True,exist_ok=True)
fontpath="C:/Windows/Fonts/segoeui.ttf"
boldpath="C:/Windows/Fonts/segoeuib.ttf"
def font(size,bold=False): return ImageFont.truetype(boldpath if bold else fontpath,size)
def diagram(name,title,subtitle,nodes,edges):
 im=Image.new("RGB",(1440,940),"#080b11");d=ImageDraw.Draw(im)
 d.text((60,35),"SENTINEL / TECHNICAL DOCUMENTATION",font=font(15,True),fill="#3378ff")
 d.text((60,76),title,font=font(36,True),fill="white")
 d.text((60,132),subtitle,font=font(18),fill="#98a5bc")
 for a,b,label in edges:
  x,y,w,h,_,_=nodes[a];xx,yy,ww,hh,_,_=nodes[b]
  start=(x+w/2,y+h/2);end=(xx+ww/2,yy+hh/2)
  dx=end[0]-start[0];dy=end[1]-start[1]
  if abs(dx)>abs(dy): start=(x+w if dx>0 else x,y+h/2);end=(xx if dx>0 else xx+ww,yy+hh/2)
  else:start=(x+w/2,y+h if dy>0 else y);end=(xx+ww/2,yy if dy>0 else yy+hh)
  d.line((start,end),fill="#3378ff",width=3)
  ang=math.atan2(end[1]-start[1],end[0]-start[0])
  tip=[end,(end[0]-13*math.cos(ang-.5),end[1]-13*math.sin(ang-.5)),(end[0]-13*math.cos(ang+.5),end[1]-13*math.sin(ang+.5))]
  d.polygon(tip,fill="#3378ff")
  if label:
   mid=((start[0]+end[0])/2,(start[1]+end[1])/2)
   box=d.textbbox((0,0),label,font=font(13));tw=box[2]-box[0]
   d.rectangle((mid[0]-tw/2-6,mid[1]-13,mid[0]+tw/2+6,mid[1]+13),fill="#080b11")
   d.text((mid[0]-tw/2,mid[1]-10),label,font=font(13),fill="#98a5bc")
 for x,y,w,h,label,body in nodes:
  d.rounded_rectangle((x,y,x+w,y+h),radius=15,fill="#10151f",outline="#2c4264",width=2)
  d.rectangle((x+18,y+21,x+22,y+45),fill="#3378ff")
  d.text((x+36,y+20),label,font=font(22,True),fill="white")
  for i,line in enumerate(body.split("\n")):d.text((x+24,y+60+i*24),line,font=font(16),fill="#98a5bc")
 d.text((60,894),"Flutter  /  ASP.NET Core  /  Microsoft SQL Server",font=font(15),fill="#98a5bc")
 im.save(root/name)
diagram("system-architecture.png","System architecture","Owner-scoped REST services connect the Flutter workspace to SQL Server and private evidence storage.",[
 (60,240,340,150,"Flutter workspace","Black / blue / white UI\nSecure token storage"),
 (550,240,340,150,"ASP.NET Core API","JWT / ownership / validation\nRate limits / audit logging"),
 (1040,240,340,150,"SQL Server","Users, cases and findings\nEvidence / reports / audit"),
 (60,565,340,150,"OSINT services","Validation and live DNS\nPublic-source research leads"),
 (550,565,340,150,"Forensics services","SHA-256 / image properties\nEXIF / optional Tesseract OCR"),
 (1040,565,340,150,"Private file storage","Original evidence bytes\nGenerated PDF reports")
],[(0,1,"JSON + JWT"),(1,2,"EF Core"),(1,3,"research"),(1,4,"ingest"),(4,5,"preserve")])
diagram("database-erd.png","Database entity relationships","SQL Server foreign keys restrict destructive deletion of cases containing investigation records.",[
 (60,230,300,150,"Users","PK Id\nUsername / PasswordHash / Role"),
 (540,230,340,150,"Cases","PK Id  /  FK CreatedBy\nNumber / Title / Status / Priority"),
 (1060,230,320,150,"AuditLogs","PK Id  /  nullable UserId\nAction / Timestamp / RequestIp"),
 (60,520,320,155,"Investigations","PK Id  /  FK CaseId\nInputType / InputValueHash"),
 (560,520,320,155,"Evidence","PK Id  /  FK CaseId\nSHA-256 / Metadata / Integrity"),
 (1060,520,320,155,"Reports","PK Id  /  FK CaseId\nPrivate path / CreatedAt"),
 (60,725,320,120,"Findings","FK InvestigationId\nValue / Source / Confidence")
],[(0,1,"1 : many"),(1,3,"1 : many"),(1,4,"1 : many"),(1,5,"1 : many"),(3,6,"1 : many")])
diagram("data-flow.png","Investigation data flow","The original evidence bytes and the analyst's findings are stored separately, linked by case.",[
 (80,220,340,145,"01  Authenticate","Credentials -> JWT\nSelect or create an owned case"),
 (550,220,340,145,"02  Collect","Enter a lead or upload a file\nValidate size, syntax, signature"),
 (1020,220,340,145,"03  Analyze","OSINT / DNS / metadata\nSHA-256 / optional OCR"),
 (1020,555,340,145,"04  Persist","Save findings to SQL Server\nPreserve original evidence"),
 (550,555,340,145,"05  Review","Inspect sources and graph\nRecompute evidence hashes"),
 (80,555,340,145,"06  Report","Recheck evidence integrity\nGenerate / download PDF")
],[(0,1,""),(1,2,""),(2,3,""),(3,4,""),(4,5,"")])
diagram("osint-workflow.png","OSINT research workflow","A public URL is a lead; a matching handle never establishes a person's identity.",[
 (80,230,350,150,"Case + input","Phone / email / username\nDomain / IPv4 / IPv6"),
 (545,230,350,150,"Validate + normalize","Reject malformed input\nCheck ownership before research"),
 (1010,230,350,150,"Run bounded research","Live DNS where applicable\nGenerate curated source links"),
 (1010,560,350,150,"Record observations","Persist findings and provenance\nMark unverified leads clearly"),
 (545,560,350,150,"Correlate","Case membership edges\nRepeated normalized input hashes"),
 (80,560,350,150,"Analyst review","Review each source manually\nPreserve supporting evidence")
],[(0,1,""),(1,2,""),(2,3,""),(3,4,""),(4,5,"")])
print("Generated 4 technical diagrams.")
