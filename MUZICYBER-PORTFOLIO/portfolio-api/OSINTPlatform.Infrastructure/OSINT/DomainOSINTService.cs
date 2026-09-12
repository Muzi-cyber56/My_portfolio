using System.Net;
using System.Net.Sockets;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.OSINT;
public sealed class DomainOSINTService : IDomainOSINTService
{
 public async Task<IReadOnlyList<FindingDto>> LookupAsync(string value,CancellationToken ct)
 {
  var domain=PublicSourceManager.Domain(value);
  var results=new List<FindingDto> { new("Domain",domain),new("Registration lead","Unverified registration lookup.","https://lookup.icann.org/en/lookup?name="+Uri.EscapeDataString(domain),0) };
  using var timeout=CancellationTokenSource.CreateLinkedTokenSource(ct); timeout.CancelAfter(TimeSpan.FromSeconds(8));
  try {
   var ips=await Dns.GetHostAddressesAsync(domain,timeout.Token);
   results.AddRange(ips.Distinct().Select(ip=>new FindingDto("DNS address",ip.ToString(),"",1)));
   if(ips.Length==0) results.Add(new("DNS status","No A/AAAA records returned.",Confidence:0));
  } catch(SocketException) { results.Add(new("DNS status","DNS resolution failed; this does not prove the domain is unregistered.",Confidence:0)); }
    catch(OperationCanceledException) when(!ct.IsCancellationRequested) { results.Add(new("DNS status","Resolver timed out. Retry later.",Confidence:0)); }
  return results;
 }
}
