using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record UsernameOSINTDto(Guid CaseId, [Required, StringLength(254)] string Value);
