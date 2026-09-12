using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IIPOSINTService
{
Task<IReadOnlyList<FindingDto>> LookupAsync(string value, CancellationToken ct);
}
