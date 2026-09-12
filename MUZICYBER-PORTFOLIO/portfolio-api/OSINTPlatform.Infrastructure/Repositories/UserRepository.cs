using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.Entities;
using OSINTPlatform.Infrastructure.Data;
namespace OSINTPlatform.Infrastructure.Repositories;
public sealed class UserRepository(ApplicationDbContext db)
{
 public Task<User?> FindAsync(string username, CancellationToken ct) => db.Users.SingleOrDefaultAsync(x=>x.Username==username,ct);
}
