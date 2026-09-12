using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
namespace OSINTPlatform.Infrastructure.Security;
public static class RateLimitService
{
 public static IServiceCollection AddPlatformRateLimits(this IServiceCollection services) => services.AddRateLimiter(o=>{
  o.RejectionStatusCode=StatusCodes.Status429TooManyRequests;
  o.GlobalLimiter=PartitionedRateLimiter.Create<HttpContext,string>(c=>RateLimitPartition.GetFixedWindowLimiter(c.User.Identity?.IsAuthenticated==true ? c.User.UserId().ToString() : c.Connection.RemoteIpAddress?.ToString() ?? "unknown",_=>new FixedWindowRateLimiterOptions { PermitLimit=120, Window=TimeSpan.FromMinutes(1), QueueLimit=0, AutoReplenishment=true }));
  o.AddPolicy("auth",c=>RateLimitPartition.GetFixedWindowLimiter(c.Connection.RemoteIpAddress?.ToString() ?? "unknown",_=>new FixedWindowRateLimiterOptions { PermitLimit=10, Window=TimeSpan.FromMinutes(1), QueueLimit=0, AutoReplenishment=true }));
 });
}
