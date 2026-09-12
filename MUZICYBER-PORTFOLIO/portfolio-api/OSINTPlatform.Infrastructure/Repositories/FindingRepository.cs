using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Forensics;
namespace OSINTPlatform.Infrastructure.Repositories;
public sealed class FindingRepository(ApplicationDbContext db, ICaseService cases)
{
 public async Task<LookupResult> SaveAsync(Guid caseId, Guid userId, string type, string input, IReadOnlyList<FindingDto> results, CancellationToken ct)
 {
  await cases.GetAsync(caseId,userId,ct);
  var inv=new Investigation { CaseId=caseId, InputType=type, InputValueHash=HashingService.Hash(System.Text.Encoding.UTF8.GetBytes(input.Trim().ToLowerInvariant())) };
  db.Investigations.Add(inv);
  db.Findings.AddRange(results.Select(f=>new Finding { InvestigationId=inv.Id, FindingType=f.FindingType, Value=f.Value, SourceUrl=f.SourceUrl, Confidence=f.Confidence }));
  await db.SaveChangesAsync(ct);
  return new(inv.Id, "Completed", results, "Validation and public-source leads only. A suggested URL does not confirm an account or identity.");
 }
 public async Task<List<Finding>> ListAsync(Guid caseId, Guid userId, CancellationToken ct)
 {
  await cases.GetAsync(caseId,userId,ct);
  return await db.Findings.AsNoTracking().Where(x=>db.Investigations.Any(i=>i.Id==x.InvestigationId && i.CaseId==caseId)).OrderByDescending(x=>x.CreatedAt).ToListAsync(ct);
 }
}
