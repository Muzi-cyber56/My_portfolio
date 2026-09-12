namespace OSINTPlatform.Core.Entities;

public sealed class Evidence
{
public Guid Id { get; set; } = Guid.NewGuid();
public Guid CaseId { get; set; }
public string EvidenceType { get; set; } = "";
public string Source { get; set; } = "";
public string OriginalName { get; set; } = "";
[System.Text.Json.Serialization.JsonIgnore]
public string StoragePath { get; set; } = "";
public string Sha256 { get; set; } = "";
public string Metadata { get; set; } = "{}";
public DateTimeOffset CollectedAt { get; set; } = DateTimeOffset.UtcNow;
public string IntegrityStatus { get; set; } = "Verified";
public DateTimeOffset? LastVerifiedAt { get; set; }
public long Size { get; set; }
}
