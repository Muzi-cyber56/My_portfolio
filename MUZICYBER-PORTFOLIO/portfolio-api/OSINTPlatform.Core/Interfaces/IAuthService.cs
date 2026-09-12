using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Core.Interfaces;
public interface IAuthService
{
Task<AuthResult?> LoginAsync(LoginDto request, CancellationToken ct);
Task<AuthResult> RegisterAsync(LoginDto request, CancellationToken ct);
}
