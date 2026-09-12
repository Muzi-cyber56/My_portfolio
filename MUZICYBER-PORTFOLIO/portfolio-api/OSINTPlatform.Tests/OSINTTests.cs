using OSINTPlatform.Core;
using OSINTPlatform.Infrastructure.OSINT;
namespace OSINTPlatform.Tests;
public sealed class OSINTTests
{
 [Theory][InlineData("https://example.com/path")][InlineData("localhost")][InlineData("foo..com")][InlineData("127.0.0.1")] public void DomainRejectsUrlsAndInvalidNames(string value)=>Assert.Throws<ValidationException>(()=>PublicSourceManager.Domain(value));
 [Fact] public void DomainNormalizesCase()=>Assert.Equal("example.com",PublicSourceManager.Domain("EXAMPLE.COM."));
 [Fact] public async Task UsernameLeadsAreNeverPresentedAsVerified(){var r=await new UsernameOSINTService().LookupAsync("analyst",default);Assert.All(r,x=>Assert.Equal(0,x.Confidence));}
 [Fact] public async Task PhoneRejectsLocalFormat()=>await Assert.ThrowsAsync<ValidationException>(()=>new PhoneOSINTService(new HttpClient(),new Microsoft.Extensions.Configuration.ConfigurationBuilder().Build()).LookupAsync("03001234567",default));
 [Fact] public async Task EmailRejectsDisplayName()=>await Assert.ThrowsAsync<ValidationException>(()=>new EmailOSINTService().LookupAsync("Name <test@example.com>",default));
 [Theory][InlineData("127.0.0.1")][InlineData("10.1.1.1")][InlineData("::1")][InlineData("::ffff:192.168.1.1")] public void LocalAddressesAreNotPublic(string value)=>Assert.False(PublicSourceManager.IsPublic(System.Net.IPAddress.Parse(value)));
}
