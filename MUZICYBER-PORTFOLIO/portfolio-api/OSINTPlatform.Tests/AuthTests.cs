using OSINTPlatform.Infrastructure.Security;
using OSINTPlatform.Core.DTOs;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
namespace OSINTPlatform.Tests;
public sealed class AuthTests
{
 [Fact] public void PasswordHashIsSaltedAndVerifiable() { var s=new PasswordService();var a=s.Hash("investigation-passphrase");var b=s.Hash("investigation-passphrase");Assert.NotEqual(a,b);Assert.True(s.Verify("investigation-passphrase",a));Assert.False(s.Verify("wrong",a)); }
 [Theory][InlineData("")][InlineData("garbage")][InlineData("PBKDF2-SHA512.999999999.AA.AA")] public void MalformedHashesAreRejected(string encoded)=>Assert.False(new PasswordService().Verify("password",encoded));
 [Fact] public void ShortPasswordsFailDtoValidation() { var rules=typeof(LoginDto).GetConstructors().Single(c=>c.IsPublic).GetParameters().Single(p=>p.Name=="Password").GetCustomAttributes<ValidationAttribute>();Assert.Contains(rules,r=>!r.IsValid("short")); }
}
