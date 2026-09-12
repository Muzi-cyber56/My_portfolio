using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Repositories;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/cases"),Authorize(Roles="Analyst,Admin")]
public sealed class CasesController(ICaseService cases,FindingRepository findings) : ControllerBase
{
 [HttpGet] public async Task<IActionResult> List(CancellationToken ct)=>Ok(await cases.ListAsync(User.UserId(),ct));
 [HttpGet("{id:guid}")] public async Task<IActionResult> Get(Guid id,CancellationToken ct)=>Ok(await cases.GetAsync(id,User.UserId(),ct));
 [HttpPost] public async Task<IActionResult> Create(CaseDto r,CancellationToken ct) { var c=await cases.CreateAsync(r,User.UserId(),ct);return CreatedAtAction(nameof(Get),new { id=c.Id },c); }
 [HttpPut("{id:guid}")] public async Task<IActionResult> Update(Guid id,CaseDto r,CancellationToken ct)=>Ok(await cases.UpdateAsync(id,r,User.UserId(),ct));
 [HttpDelete("{id:guid}")] public async Task<IActionResult> Delete(Guid id,CancellationToken ct) { await cases.DeleteAsync(id,User.UserId(),ct);return NoContent(); }
 [HttpGet("{id:guid}/findings")] public async Task<IActionResult> Findings(Guid id,CancellationToken ct)=>Ok(await findings.ListAsync(id,User.UserId(),ct));
}
