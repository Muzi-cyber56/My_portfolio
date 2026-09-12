using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using OSINTPlatform.Core;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Forensics;
namespace OSINTPlatform.Infrastructure.Repositories;
public sealed class EvidenceRepository(ApplicationDbContext db, ICaseService cases, FileValidationService validator, IImageForensicsService images, EvidenceIntegrityService integrity,IConfiguration config) : IEvidenceService
{
 public async Task<Evidence> AddAsync(Guid caseId,Guid userId,string name,string source,byte[] data,bool imageOnly,CancellationToken ct)
 {
  await cases.GetAsync(caseId,userId,ct);
  name=Path.GetFileName(name.Replace('\\','/'));
  if(name.Length>255 || source.Length>2048) throw new ValidationException("File name or source is too long.");
  var mime=validator.Validate(name,data,imageOnly);
  var e=new Evidence { CaseId=caseId, OriginalName=name, Source=source, EvidenceType=mime, Sha256=HashingService.Hash(data), Size=data.Length,LastVerifiedAt=DateTimeOffset.UtcNow };
  if(mime.StartsWith("image/")) e.Metadata=JsonSerializer.Serialize(await images.AnalyzeAsync(data,ct),new JsonSerializerOptions(JsonSerializerDefaults.Web));
  var folder=Path.Combine(config["Storage:Root"]!, "evidence",mime.StartsWith("image/") ? "images" : "documents");
  Directory.CreateDirectory(folder); e.StoragePath=Path.Combine(folder,e.Id.ToString("N")+".bin");
  await File.WriteAllBytesAsync(e.StoragePath,data,ct);
  try { db.Evidence.Add(e); await db.SaveChangesAsync(ct); }
  catch { File.Delete(e.StoragePath); throw; }
  return e;
 }
 public async Task<List<Evidence>> ListAsync(Guid caseId,Guid userId,CancellationToken ct) {
  await cases.GetAsync(caseId,userId,ct); return await db.Evidence.AsNoTracking().Where(x=>x.CaseId==caseId).OrderByDescending(x=>x.CollectedAt).ToListAsync(ct);
 }
 private async Task<Evidence> GetAsync(Guid caseId,Guid evidenceId,Guid userId,CancellationToken ct) {
  await cases.GetAsync(caseId,userId,ct);return await db.Evidence.FirstOrDefaultAsync(x=>x.Id==evidenceId && x.CaseId==caseId,ct) ?? throw new MissingException();
 }
 public async Task<(Evidence Record,byte[] Bytes)> ReadAsync(Guid caseId,Guid evidenceId,Guid userId,CancellationToken ct) {
  var e=await GetAsync(caseId,evidenceId,userId,ct);
  if(!File.Exists(e.StoragePath)) throw new MissingException("Evidence file is missing.");
  var bytes=await File.ReadAllBytesAsync(e.StoragePath,ct);
  e.IntegrityStatus=integrity.Verify(bytes,e.Sha256) ? "Verified" : "Mismatch";e.LastVerifiedAt=DateTimeOffset.UtcNow;await db.SaveChangesAsync(ct);
  if(e.IntegrityStatus!="Verified") throw new ConflictException("Evidence integrity mismatch. Download blocked.");
  return(e,bytes);
 }
 public async Task<Evidence> VerifyAsync(Guid caseId,Guid evidenceId,Guid userId,CancellationToken ct) {
  var e=await GetAsync(caseId,evidenceId,userId,ct);
  e.IntegrityStatus=!File.Exists(e.StoragePath) ? "Missing" : integrity.Verify(await File.ReadAllBytesAsync(e.StoragePath,ct),e.Sha256) ? "Verified" : "Mismatch";
  e.LastVerifiedAt=DateTimeOffset.UtcNow;await db.SaveChangesAsync(ct);return e;
 }
}
