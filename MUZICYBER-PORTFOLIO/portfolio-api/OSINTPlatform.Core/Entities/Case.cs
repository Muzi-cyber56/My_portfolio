namespace OSINTPlatform.Core.Entities;

public sealed class Case
{
public Guid Id { get; set; } = Guid.NewGuid();
public string CaseNumber { get; set; } = "";
public string Title { get; set; } = "";
public string Description { get; set; } = "";
public string Status { get; set; } = "Open";
public string Priority { get; set; } = "Normal";
public Guid CreatedBy { get; set; }
public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
