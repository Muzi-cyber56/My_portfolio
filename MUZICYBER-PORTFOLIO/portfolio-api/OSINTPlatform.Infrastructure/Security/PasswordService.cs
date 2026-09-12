using System.Security.Cryptography;
namespace OSINTPlatform.Infrastructure.Security;
public sealed class PasswordService
{
 private const int Iterations=210000;
 public string Hash(string password)
 {
  byte[] salt=RandomNumberGenerator.GetBytes(16);
  byte[] hash=Rfc2898DeriveBytes.Pbkdf2(password,salt,Iterations,HashAlgorithmName.SHA512,32);
  return $"PBKDF2-SHA512.{Iterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
 }
 public bool Verify(string password,string encoded)
 {
  try {
   var p=encoded.Split('.');
   if(p.Length!=4 || p[0]!="PBKDF2-SHA512" || !int.TryParse(p[1],out int rounds) || rounds<100000 || rounds>1000000) return false;
   var actual=Rfc2898DeriveBytes.Pbkdf2(password,Convert.FromBase64String(p[2]),rounds,HashAlgorithmName.SHA512,32);
   return CryptographicOperations.FixedTimeEquals(actual,Convert.FromBase64String(p[3]));
  } catch(FormatException) { return false; }
 }
}
