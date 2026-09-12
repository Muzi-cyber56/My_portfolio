using System.ComponentModel.DataAnnotations;
using System.Reflection;
using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Infrastructure.Data;
namespace OSINTPlatform.Tests;
public sealed class CaseTests
{
 [Theory][InlineData("Invalid")][InlineData("")] public void InvalidStatusFails(string status) { var rules=typeof(CaseDto).GetConstructors().Single(c=>c.IsPublic).GetParameters().Single(p=>p.Name=="Status").GetCustomAttributes<ValidationAttribute>();Assert.Contains(rules,r=>!r.IsValid(status)); }
 [Fact] public void SqlServerSchemaContainsRelationshipsAndUniqueCaseNumber() {
  using var db=new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseSqlServer("Server=localhost;Database=unused;Trusted_Connection=True").Options);
  var sql=db.Database.GenerateCreateScript();Assert.Contains("CREATE TABLE [Evidence]",sql);Assert.Contains("FOREIGN KEY ([CaseId])",sql);Assert.Contains("CREATE UNIQUE INDEX [IX_Cases_CaseNumber]",sql);
 }
}
