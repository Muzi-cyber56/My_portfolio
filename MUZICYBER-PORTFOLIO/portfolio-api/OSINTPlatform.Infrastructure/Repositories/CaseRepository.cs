using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
namespace OSINTPlatform.Infrastructure.Repositories;
public sealed class CaseRepository(ApplicationDbContext db) : ICaseService
{
 public Task<List<Case>> ListAsync(Guid userId, CancellationToken ct) => db.Cases.AsNoTracking().Where(x=>x.CreatedBy==userId).OrderByDescending(x=>x.CreatedAt).ToListAsync(ct);
 public async Task<Case> GetAsync(Guid id, Guid userId, CancellationToken ct) => await db.Cases.FirstOrDefaultAsync(x=>x.Id==id && x.CreatedBy==userId,ct) ?? throw new MissingException();
 public async Task<Case> CreateAsync(CaseDto request, Guid userId, CancellationToken ct)
 {
  var item = new Case { Title=request.Title.Trim(), Description=request.Description.Trim(), Status=request.Status, Priority=request.Priority, CreatedBy=userId };
  item.CaseNumber=$"INV-{DateTime.UtcNow:yyyy}-{item.Id.ToString("N")[..8].ToUpperInvariant()}";
  db.Cases.Add(item); await db.SaveChangesAsync(ct); return item;
 }
 public async Task<Case> UpdateAsync(Guid id, CaseDto r, Guid userId, CancellationToken ct)
 {
  var item=await GetAsync(id,userId,ct); item.Title=r.Title.Trim(); item.Description=r.Description.Trim(); item.Status=r.Status; item.Priority=r.Priority;
  await db.SaveChangesAsync(ct); return item;
 }
 public async Task DeleteAsync(Guid id, Guid userId, CancellationToken ct)
 {
  var item=await GetAsync(id,userId,ct);
  if(await db.Investigations.AnyAsync(x=>x.CaseId==id,ct) || await db.Evidence.AnyAsync(x=>x.CaseId==id,ct) || await db.Reports.AnyAsync(x=>x.CaseId==id,ct))
   throw new ConflictException("Cases with findings, evidence or reports cannot be deleted. Close the case to preserve its record.");
  db.Cases.Remove(item);
  try { await db.SaveChangesAsync(ct); } catch(DbUpdateException) { throw new ConflictException("Case has linked records. Close it instead."); }
 }
}
