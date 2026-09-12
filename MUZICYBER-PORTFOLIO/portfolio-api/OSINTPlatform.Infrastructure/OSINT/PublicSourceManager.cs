using System.Net;
using OSINTPlatform.Core;
namespace OSINTPlatform.Infrastructure.OSINT;
public static class PublicSourceManager
{
 public static string Domain(string input)
 {
  var value=input.Trim().TrimEnd('.').ToLowerInvariant();
  try { value=new System.Globalization.IdnMapping().GetAscii(value); } catch(ArgumentException) { throw new ValidationException("Enter a valid domain name."); }
  if(value.Length>253 || !value.Contains('.') || IPAddress.TryParse(value,out _) || value.Split('.').Any(l=>l.Length<1 || l.Length>63 || !System.Text.RegularExpressions.Regex.IsMatch(l,@"^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$")))
   throw new ValidationException("Enter a domain such as example.com, without a URL or path.");
  return value;
 }
 public static bool IsPublic(IPAddress ip)
 {
  if(ip.IsIPv4MappedToIPv6) ip=ip.MapToIPv4();
  var b=ip.GetAddressBytes();
  if(IPAddress.IsLoopback(ip)) return false;
  if(b.Length==16) return (b[0] & 0xe0)==0x20 && !(b[0]==0x20 && b[1]==1 && b[2]==0x0d && b[3]==0xb8);
  return b[0]!=0 && b[0]!=10 && b[0]!=127 && b[0]<224 && !(b[0]==169 && b[1]==254) && !(b[0]==172 && b[1]>=16 && b[1]<=31) && !(b[0]==192 && b[1]==168) && !(b[0]==100 && b[1]>=64 && b[1]<=127) && !(b[0]==198 && (b[1]==18 || b[1]==19));
 }
}
