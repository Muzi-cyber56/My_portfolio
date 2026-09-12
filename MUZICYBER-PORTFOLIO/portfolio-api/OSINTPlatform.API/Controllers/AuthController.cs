using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/auth"),EnableRateLimiting("auth")]
public sealed class AuthController(IAuthService auth) : ControllerBase
{
 [HttpPost("register")] public async Task<IActionResult> Register(LoginDto r,CancellationToken ct)=>Ok(await auth.RegisterAsync(r,ct));
 [HttpPost("login")] public async Task<IActionResult> Login(LoginDto r,CancellationToken ct) {
  var result=await auth.LoginAsync(r,ct);return result is null ? Unauthorized(new { title="Invalid username or password." }) : Ok(result);
 }
}
