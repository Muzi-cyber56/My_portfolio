using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface ICaseService
{
Task<List<Case>> ListAsync(Guid userId, CancellationToken ct);
Task<Case> GetAsync(Guid id, Guid userId, CancellationToken ct);
Task<Case> CreateAsync(CaseDto request, Guid userId, CancellationToken ct);
Task<Case> UpdateAsync(Guid id, CaseDto request, Guid userId, CancellationToken ct);
Task DeleteAsync(Guid id, Guid userId, CancellationToken ct);
}
