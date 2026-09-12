using Microsoft.AspNetCore.Mvc;
using OSINTPlatform.Core;
namespace OSINTPlatform.API.Middleware;
public sealed class ExceptionMiddleware(RequestDelegate next,ILogger<ExceptionMiddleware> logger)
{
 public async Task InvokeAsync(HttpContext c)
 {
  try { await next(c); }
  catch(OperationCanceledException) when(c.RequestAborted.IsCancellationRequested) { c.Response.StatusCode=499; }
  catch(Exception e) {
   int status=e switch { ValidationException=>400, MissingException=>404, ConflictException=>409, UnauthorizedAccessException=>401, BadHttpRequestException b=>b.StatusCode, _=>500 };
   if(status==500) logger.LogError(e,"Request failed: {TraceId}",c.TraceIdentifier);
   if(c.Response.HasStarted) throw;
   c.Response.Clear();c.Response.StatusCode=status;
   await c.Response.WriteAsJsonAsync(new ProblemDetails { Status=status, Title=status==500 ? "The request could not be completed. Check server logs." : e.Message, Extensions={["traceId"]=c.TraceIdentifier} });
  }
 }
}
