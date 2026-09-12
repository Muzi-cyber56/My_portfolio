using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Forensics;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/evidence"),Authorize]
public sealed class EvidenceController(IEvidenceService evidence) : ControllerBase
{
 [HttpPost,RequestSizeLimit(FileValidationService.MaxBytes+65536)]
 public async Task<IActionResult> Upload([FromForm] Guid caseId,[FromForm] IFormFile file,[FromForm] string source,CancellationToken ct) {
  using var stream=new MemoryStream();await file.CopyToAsync(stream,ct);
  return Ok(await evidence.AddAsync(caseId,User.UserId(),file.FileName,source,stream.ToArray(),false,ct));
 }
 [HttpGet("{caseId:guid}")] public async Task<IActionResult> List(Guid caseId,CancellationToken ct)=>Ok(await evidence.ListAsync(caseId,User.UserId(),ct));
 [HttpGet("{caseId:guid}/{evidenceId:guid}")] public async Task<IActionResult> Download(Guid caseId,Guid evidenceId,CancellationToken ct) {
  var (e,bytes)=await evidence.ReadAsync(caseId,evidenceId,User.UserId(),ct);return File(bytes,"application/octet-stream",e.OriginalName);
 }
 [HttpPost("{caseId:guid}/{evidenceId:guid}/verify")] public async Task<IActionResult> Verify(Guid caseId,Guid evidenceId,CancellationToken ct)=>Ok(await evidence.VerifyAsync(caseId,evidenceId,User.UserId(),ct));
}
