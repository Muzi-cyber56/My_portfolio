using System.Security.Cryptography;
namespace OSINTPlatform.Infrastructure.Forensics;
public static class HashingService
{
 public static string Hash(byte[] bytes)=>Convert.ToHexStringLower(SHA256.HashData(bytes));
}
