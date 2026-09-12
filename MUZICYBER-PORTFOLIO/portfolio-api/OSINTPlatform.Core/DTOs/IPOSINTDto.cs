using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record IPOSINTDto(Guid CaseId, [Required, StringLength(254)] string Value);
