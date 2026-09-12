using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record EmailOSINTDto(Guid CaseId, [Required, StringLength(254)] string Value);
