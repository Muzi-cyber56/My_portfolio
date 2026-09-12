using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Forensics;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/forensics/image"),Authorize]
public sealed class ImageForensicsController(IEvidenceService evidence) : ControllerBase
{
 [HttpPost,RequestSizeLimit(FileValidationService.MaxBytes+65536)]
 public async Task<IActionResult> Analyze([FromForm] Guid caseId,[FromForm] IFormFile file,[FromForm] string source,CancellationToken ct) {
  using var stream=new MemoryStream();await file.CopyToAsync(stream,ct);
  return Ok(await evidence.AddAsync(caseId,User.UserId(),file.FileName,source,stream.ToArray(),true,ct));
 }
}
