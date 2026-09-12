using OSINTPlatform.Core.Entities;
using OSINTPlatform.Infrastructure.Data;
using System.Security.Claims;
namespace OSINTPlatform.API.Middleware;
public sealed class AuditMiddleware(RequestDelegate next,ILogger<AuditMiddleware> logger)
{
 public async Task InvokeAsync(HttpContext context,ApplicationDbContext db)
 {
  await next(context);
  if(!context.Request.Path.StartsWithSegments("/api")) return;
  Guid? userId=Guid.TryParse(context.User.FindFirstValue(ClaimTypes.NameIdentifier),out var id) ? id : null;
  // Isolate logging from failed entity changes in the request's DbContext.
  db.ChangeTracker.Clear();
  db.AuditLogs.Add(new AuditLog { UserId=userId, Action=$"{context.Request.Method} {context.Request.Path} {context.Response.StatusCode}", RequestIp=context.Connection.RemoteIpAddress?.ToString() ?? "" });
  try { await db.SaveChangesAsync(CancellationToken.None); } catch(Exception ex) { logger.LogError(ex,"Audit write failed for {TraceId}",context.TraceIdentifier); }
 }
}
