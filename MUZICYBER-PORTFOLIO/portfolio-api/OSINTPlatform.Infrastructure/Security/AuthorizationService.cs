using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
namespace OSINTPlatform.Infrastructure.Security;
public static class UserIdentity
{
 public static Guid UserId(this ClaimsPrincipal user) => Guid.Parse(user.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new UnauthorizedAccessException());
}
public sealed class AuthorizationService(ApplicationDbContext db, PasswordService passwords, JwtService jwt) : IAuthService
{
 private static readonly string DummyHash=new PasswordService().Hash("timing-only-dummy-password");
 public async Task<AuthResult?> LoginAsync(LoginDto r,CancellationToken ct)
 {
  var name=Normalize(r.Username);
  var user=await db.Users.SingleOrDefaultAsync(x=>x.Username==name,ct);
  var valid=passwords.Verify(r.Password,user?.PasswordHash ?? DummyHash);
  return user is not null && valid ? jwt.Issue(user) : null;
 }
 public async Task<AuthResult> RegisterAsync(LoginDto r,CancellationToken ct)
 {
  var name=Normalize(r.Username);
  if(!System.Text.RegularExpressions.Regex.IsMatch(name,@"^[a-z0-9_.-]{3,50}$")) throw new ValidationException("Username must use 3–50 letters, numbers, dots, underscores or hyphens.");
  if(await db.Users.AnyAsync(x=>x.Username==name,ct)) throw new ConflictException("Username is unavailable.");
  var user=new User { Username=name, PasswordHash=passwords.Hash(r.Password) };
  db.Users.Add(user);
  try { await db.SaveChangesAsync(ct); } catch(DbUpdateException) { throw new ConflictException("Unable to create account. Username may be unavailable."); }
  return jwt.Issue(user);
 }
 private static string Normalize(string name)=>name.Trim().ToLowerInvariant();
}
