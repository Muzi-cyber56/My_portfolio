using System.Net;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.OSINT;
public sealed class IPOSINTService : IIPOSINTService
{
 public Task<IReadOnlyList<FindingDto>> LookupAsync(string value,CancellationToken ct)
 {
  if(!IPAddress.TryParse(value.Trim(),out var ip)) throw new ValidationException("Enter a valid IPv4 or IPv6 address.");
  var results=new List<FindingDto> { new("IP address",ip.ToString()),new("Address family",ip.AddressFamily.ToString()) };
  if(PublicSourceManager.IsPublic(ip)) results.Add(new("Registration lead","Unverified IP registration lookup.","https://rdap.org/ip/"+Uri.EscapeDataString(ip.ToString()),0));
  else results.Add(new("Scope","Local, private, or special-use address; no public attribution.",Confidence:1));
  results.Add(new("Attribution","An IP address alone does not identify a person or precise location.",Confidence:0));
  return Task.FromResult<IReadOnlyList<FindingDto>>(results);
 }
}
