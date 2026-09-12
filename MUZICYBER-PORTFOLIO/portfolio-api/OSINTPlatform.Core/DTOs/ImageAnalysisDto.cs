using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record ImageAnalysisDto(Guid CaseId, string FileName, string Source);
