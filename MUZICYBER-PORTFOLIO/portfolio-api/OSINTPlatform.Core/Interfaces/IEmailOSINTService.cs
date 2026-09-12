using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IEmailOSINTService
{
Task<IReadOnlyList<FindingDto>> LookupAsync(string value, CancellationToken ct);
}
