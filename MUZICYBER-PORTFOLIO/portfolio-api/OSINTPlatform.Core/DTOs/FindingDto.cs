using System.ComponentModel.DataAnnotations;
namespace OSINTPlatform.Core.DTOs;
public sealed record FindingDto(string FindingType, string Value, string SourceUrl = "", double Confidence = 1);
public sealed record LookupRequest(Guid CaseId, [Required, StringLength(254, MinimumLength = 1)] string Value);
public sealed record LookupResult(Guid InvestigationId, string Status, IReadOnlyList<FindingDto> Findings, string Notice);
public sealed record CnicRequest([Required, StringLength(15)] string Value);
public sealed record ImageAnalysisDtoResult(string Format, int? Width, int? Height, string Sha256, string MetadataStatus, string OcrStatus, IReadOnlyDictionary<string,string> Tags, string OcrText);
