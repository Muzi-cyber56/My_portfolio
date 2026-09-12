using Microsoft.EntityFrameworkCore;
namespace OSINTPlatform.Infrastructure.Data;
public static class DbInitializer
{
 public static async Task InitializeAsync(ApplicationDbContext db, CancellationToken ct = default)
 {
  await db.Database.EnsureCreatedAsync(ct);
  await db.Database.ExecuteSqlRawAsync(@"IF OBJECT_ID(N'dbo.ContactMessages', N'U') IS NULL
BEGIN
 CREATE TABLE [ContactMessages] ([Id] uniqueidentifier NOT NULL CONSTRAINT [PK_ContactMessages] PRIMARY KEY, [Name] nvarchar(120) NOT NULL, [Email] nvarchar(254) NOT NULL, [Message] nvarchar(4000) NOT NULL, [CreatedAt] datetimeoffset NOT NULL, [Status] nvarchar(30) NOT NULL);
END", ct);
 }
}
