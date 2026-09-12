using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IImageForensicsService
{
Task<ImageAnalysisDtoResult> AnalyzeAsync(byte[] data, CancellationToken ct);
}
