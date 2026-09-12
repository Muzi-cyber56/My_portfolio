using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Security;
namespace OSINTPlatform.API.Controllers;
[ApiController,Route("api/users"),Authorize]
public sealed class UsersController(ApplicationDbContext db) : ControllerBase
{
 [HttpGet("me")] public async Task<IActionResult> Me(CancellationToken ct)=>Ok(await db.Users.Where(u=>u.Id==User.UserId()).Select(u=>new { u.Id,u.Username,u.Role,u.CreatedAt }).SingleAsync(ct));
}
