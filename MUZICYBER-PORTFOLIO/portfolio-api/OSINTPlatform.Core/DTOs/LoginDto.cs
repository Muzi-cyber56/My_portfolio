using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record LoginDto([Required, StringLength(50, MinimumLength = 3)] string Username, [Required, StringLength(128, MinimumLength = 12)] string Password);
public sealed record AuthResult(string Token, DateTimeOffset ExpiresAt, Guid UserId, string Username, string Role);
