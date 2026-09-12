using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Repositories;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/osint/ip"),Authorize]
public sealed class IPOSINTController(IIPOSINTService service,ICaseService cases,FindingRepository findings) : ControllerBase
{
 [HttpPost] public async Task<IActionResult> Lookup(IPOSINTDto r,CancellationToken ct) {
  await cases.GetAsync(r.CaseId,User.UserId(),ct);
  var result=await service.LookupAsync(r.Value,ct);
  return Ok(await findings.SaveAsync(r.CaseId,User.UserId(),"ip",r.Value,result,ct));
 }
}
