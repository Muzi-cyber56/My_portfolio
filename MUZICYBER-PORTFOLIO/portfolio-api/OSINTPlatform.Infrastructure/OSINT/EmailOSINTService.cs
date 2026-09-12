using System.Net.Mail;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.OSINT;
public sealed class EmailOSINTService : IEmailOSINTService
{
 public Task<IReadOnlyList<FindingDto>> LookupAsync(string value,CancellationToken ct)
 {
  value=value.Trim();
  if(!MailAddress.TryCreate(value,out var address) || address.Address!=value || !address.Host.Contains('.')) throw new ValidationException("Enter a valid email address.");
  var domain=PublicSourceManager.Domain(address.Host);
  return Task.FromResult<IReadOnlyList<FindingDto>>([new("Email syntax","Valid syntax; mailbox existence is unverified."),new("Mail domain",domain),new("Domain registration lead","Open the domain registration lookup for manual review.","https://lookup.icann.org/en/lookup?name="+Uri.EscapeDataString(domain),0),new("Provider status","Breach records and mailbox ownership have not been queried.",Confidence:0)]);
 }
}
