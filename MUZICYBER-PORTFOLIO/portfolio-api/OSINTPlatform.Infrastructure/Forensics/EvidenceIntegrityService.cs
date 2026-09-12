namespace OSINTPlatform.Infrastructure.Forensics;
public sealed class EvidenceIntegrityService
{
 public bool Verify(byte[] data,string sha256)=>string.Equals(HashingService.Hash(data),sha256,StringComparison.OrdinalIgnoreCase);
}
