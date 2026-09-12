using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IReportService
{
Task<Report> GenerateAsync(Guid caseId, Guid userId, CancellationToken ct);
Task<byte[]> DownloadAsync(Guid id, Guid userId, CancellationToken ct);
}
