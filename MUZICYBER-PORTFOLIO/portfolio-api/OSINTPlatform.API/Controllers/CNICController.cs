using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core.DTOs;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/forensics/cnic"),Authorize]
public sealed class CNICController : ControllerBase
{
 [HttpPost] public IActionResult Validate(CnicRequest r) {
  var value=r.Value.Trim();
  var valid=System.Text.RegularExpressions.Regex.IsMatch(value,@"^(?:[1-7][0-9]{12}|[1-7][0-9]{4}-[0-9]{7}-[0-9])$");
  return Ok(new { valid, scope="Format only", message=valid ? "CNIC format matches. Identity, issuance and ownership are not verified." : "Use 13 digits or XXXXX-XXXXXXX-X, starting with 1–7." });
 }
}
