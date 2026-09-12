using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record CaseDto([Required, StringLength(160, MinimumLength = 3)] string Title, [StringLength(4000)] string Description = "", [Required, RegularExpression("^(Open|In progress|Closed)$")] string Status = "Open", [Required, RegularExpression("^(Normal|High|Critical)$")] string Priority = "Normal");
