namespace OSINTPlatform.Core.Entities;

public sealed class Report
{
public Guid Id { get; set; } = Guid.NewGuid();
public Guid CaseId { get; set; }
[System.Text.Json.Serialization.JsonIgnore]
public string ReportPath { get; set; } = "";
public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
