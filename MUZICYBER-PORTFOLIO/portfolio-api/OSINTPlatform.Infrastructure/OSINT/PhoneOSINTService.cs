using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Configuration;
using OSINTPlatform.Core;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.OSINT;
public sealed class PhoneOSINTService(HttpClient http, IConfiguration config) : IPhoneOSINTService
{
 public async Task<IReadOnlyList<FindingDto>> LookupAsync(string value,CancellationToken ct)
 {
  var phone=Regex.Replace(value.Trim(),@"[\s()-]","");
  if(!Regex.IsMatch(phone,@"^\+[1-9][0-9]{7,14}$")) throw new ValidationException("Use international format, for example +923001234567.");
  var accessKey=config["PhoneLookup:ApiKey"];
  if(string.IsNullOrWhiteSpace(accessKey)) return [new("Phone format","Valid E.164-shaped number (not proof of an active line)."),new("Number",phone),new("Provider status","Numverify is not configured. Add PhoneLookup:ApiKey to server user-secrets.",Confidence:0)];
  using var timeout=CancellationTokenSource.CreateLinkedTokenSource(ct);timeout.CancelAfter(TimeSpan.FromSeconds(12));
  try {
   using var response=await http.GetAsync($"https://apilayer.net/api/validate?access_key={Uri.EscapeDataString(accessKey)}&number={Uri.EscapeDataString(phone)}",timeout.Token);
   if(!response.IsSuccessStatusCode) throw new InvalidOperationException($"Numverify returned HTTP {(int)response.StatusCode}.");
   using var json=JsonDocument.Parse(await response.Content.ReadAsStringAsync(timeout.Token));var root=json.RootElement;
   if(root.TryGetProperty("success",out var success) && !success.GetBoolean()) {
    var info=root.TryGetProperty("error",out var error) && error.TryGetProperty("info",out var infoValue) ? infoValue.GetString() : "Numverify rejected the request.";
    throw new InvalidOperationException(info ?? "Numverify rejected the request.");
   }
   string Text(string name)
   {
    if(!root.TryGetProperty(name,out var p) || p.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined) return "Not returned by Numverify";
    var value=p.ToString().Trim();
    return string.IsNullOrWhiteSpace(value) || value.Equals("null",StringComparison.OrdinalIgnoreCase) ? "Not returned by Numverify" : value;
   }
   var valid=root.TryGetProperty("valid",out var v) && v.ValueKind==JsonValueKind.True;
   var result=new List<FindingDto> { new("Number",Text("international_format")),new("Validity",valid ? "Provider marked this number as valid." : "Provider marked this number as invalid.",Confidence:1),new("Country",$"{Text("country_name")} ({Text("country_code")})",Confidence:1),new("Location",Text("location"),Confidence:1),new("Carrier",Text("carrier"),Confidence:1),new("Line type",Text("line_type"),Confidence:1),new("Local format",Text("local_format"),Confidence:1),new("Privacy boundary","Numverify does not prove subscriber name, CNIC, address or live location.",Confidence:0) };
   return result;
  } catch(OperationCanceledException) when(!ct.IsCancellationRequested) { return [new("Provider status","Numverify timed out. Retry later.",Confidence:0)]; }
    catch(HttpRequestException) { return [new("Provider status","Could not reach Numverify. Check server internet access and retry.",Confidence:0)]; }
    catch(JsonException) { return [new("Provider status","Numverify returned an unreadable response.",Confidence:0)]; }
    catch(InvalidOperationException e) { return [new("Provider status",e.Message,Confidence:0)]; }
 }
}
