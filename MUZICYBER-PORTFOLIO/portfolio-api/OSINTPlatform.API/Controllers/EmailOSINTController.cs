using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Repositories;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/osint/email"),Authorize]
public sealed class EmailOSINTController(IEmailOSINTService service,ICaseService cases,FindingRepository findings) : ControllerBase
{
 [HttpPost] public async Task<IActionResult> Lookup(EmailOSINTDto r,CancellationToken ct) {
  await cases.GetAsync(r.CaseId,User.UserId(),ct);
  var result=await service.LookupAsync(r.Value,ct);
  return Ok(await findings.SaveAsync(r.CaseId,User.UserId(),"email",r.Value,result,ct));
 }
}
