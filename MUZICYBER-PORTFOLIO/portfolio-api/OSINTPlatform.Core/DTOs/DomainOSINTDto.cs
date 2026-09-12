using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record DomainOSINTDto(Guid CaseId, [Required, StringLength(254)] string Value);
