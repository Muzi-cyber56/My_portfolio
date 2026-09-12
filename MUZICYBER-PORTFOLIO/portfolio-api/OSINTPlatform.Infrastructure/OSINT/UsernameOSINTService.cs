using System.Text.RegularExpressions;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.OSINT;
public sealed class UsernameOSINTService : IUsernameOSINTService
{
 public Task<IReadOnlyList<FindingDto>> LookupAsync(string value,CancellationToken ct)
 {
  value=value.Trim().TrimStart('@');
  if(!Regex.IsMatch(value,@"^[a-zA-Z0-9_.-]{1,39}$")) throw new ValidationException("Use 1–39 letters, numbers, dots, underscores or hyphens.");
  var name=Uri.EscapeDataString(value);
  return Task.FromResult<IReadOnlyList<FindingDto>>([new("GitHub lead","Unverified profile URL; open to review.","https://github.com/"+name,0),new("Reddit lead","Unverified profile URL; open to review.","https://www.reddit.com/user/"+name+"/",0),new("Attribution","A matching username does not establish a shared identity.",Confidence:0)]);
 }
}
