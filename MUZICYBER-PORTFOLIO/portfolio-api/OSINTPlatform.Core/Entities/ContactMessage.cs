namespace OSINTPlatform.Core.Entities;
public sealed class ContactMessage
{
 public Guid Id { get; set; } = Guid.NewGuid(); public string Name { get; set; } = ""; public string Email { get; set; } = ""; public string Message { get; set; } = ""; public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow; public string Status { get; set; } = "Stored";
}
