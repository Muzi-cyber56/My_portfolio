namespace OSINTPlatform.Core.Entities;

public sealed class Investigation
{
public Guid Id { get; set; } = Guid.NewGuid();
public Guid CaseId { get; set; }
public string InputType { get; set; } = "";
public string InputValueHash { get; set; } = "";
public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
