namespace OSINTPlatform.Core.Entities;

public sealed class User
{
public Guid Id { get; set; } = Guid.NewGuid();
public string Username { get; set; } = "";
public string PasswordHash { get; set; } = "";
public string Role { get; set; } = "Analyst";
public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
