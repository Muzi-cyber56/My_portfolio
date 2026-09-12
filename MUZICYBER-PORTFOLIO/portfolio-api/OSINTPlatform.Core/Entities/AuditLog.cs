namespace OSINTPlatform.Core.Entities;

public sealed class AuditLog
{
public long Id { get; set; }
public Guid? UserId { get; set; }
public string Action { get; set; } = "";
public DateTimeOffset Timestamp { get; set; } = DateTimeOffset.UtcNow;
public string RequestIp { get; set; } = "";
}
