using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/reports"),Authorize]
public sealed class ReportsController(IReportService reports,ICaseService cases,ApplicationDbContext db) : ControllerBase
{
 [HttpPost("{caseId:guid}")] public async Task<IActionResult> Generate(Guid caseId,CancellationToken ct)=>Ok(await reports.GenerateAsync(caseId,User.UserId(),ct));
 [HttpGet("case/{caseId:guid}")] public async Task<IActionResult> List(Guid caseId,CancellationToken ct) {
  await cases.GetAsync(caseId,User.UserId(),ct);return Ok(await db.Reports.AsNoTracking().Where(x=>x.CaseId==caseId).OrderByDescending(x=>x.CreatedAt).ToListAsync(ct));
 }
 [HttpGet("{id:guid}")] public async Task<IActionResult> Download(Guid id,CancellationToken ct)=>File(await reports.DownloadAsync(id,User.UserId(),ct),"application/pdf",$"investigation-{id}.pdf");
}
