namespace OSINTPlatform.Core.Entities;

public sealed class Finding
{
public Guid Id { get; set; } = Guid.NewGuid();
public Guid InvestigationId { get; set; }
public string FindingType { get; set; } = "";
public string Value { get; set; } = "";
public string SourceUrl { get; set; } = "";
public double Confidence { get; set; }
public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
