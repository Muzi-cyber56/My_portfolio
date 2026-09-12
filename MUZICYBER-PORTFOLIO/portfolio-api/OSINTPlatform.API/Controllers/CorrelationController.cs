using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/correlation"),Authorize]
public sealed class CorrelationController(ApplicationDbContext db,ICaseService cases) : ControllerBase
{
 [HttpGet("{caseId:guid}")] public async Task<IActionResult> Get(Guid caseId,CancellationToken ct) {
  var c=await cases.GetAsync(caseId,User.UserId(),ct);
  var inv=await db.Investigations.AsNoTracking().Where(x=>x.CaseId==caseId).OrderBy(x=>x.CreatedAt).ToListAsync(ct);
  var groups=inv.GroupBy(x=>x.InputValueHash).Where(g=>g.Count()>1).Select(g=>new { hash=g.Key, investigationIds=g.Select(x=>x.Id).ToArray() });
  return Ok(new { caseId,caseTitle=c.Title,nodes=inv.Select(x=>new { x.Id,label=x.InputType,x.CreatedAt }),edges=inv.Select(x=>new { from=caseId,to=x.Id,label="investigation" }),matches=groups,notice="Edges represent case membership. Matches mean identical normalized input hashes, not verified identity links." });
 }
}
