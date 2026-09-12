using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record ContactDto([Required, StringLength(120, MinimumLength=2)] string Name, [Required, EmailAddress, StringLength(254)] string Email, [Required, StringLength(4000, MinimumLength=2)] string Message);
