using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IEvidenceService
{
Task<Evidence> AddAsync(Guid caseId, Guid userId, string name, string source, byte[] data, bool imageOnly, CancellationToken ct);
Task<List<Evidence>> ListAsync(Guid caseId, Guid userId, CancellationToken ct);
Task<(Evidence Record, byte[] Bytes)> ReadAsync(Guid caseId, Guid evidenceId, Guid userId, CancellationToken ct);
Task<Evidence> VerifyAsync(Guid caseId, Guid evidenceId, Guid userId, CancellationToken ct);
}
