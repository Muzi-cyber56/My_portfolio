using Microsoft.EntityFrameworkCore;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Infrastructure.Data;
public sealed class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
 public DbSet<User> Users => Set<User>();
 public DbSet<Case> Cases => Set<Case>();
 public DbSet<Investigation> Investigations => Set<Investigation>();
 public DbSet<Finding> Findings => Set<Finding>();
 public DbSet<Evidence> Evidence => Set<Evidence>();
 public DbSet<Report> Reports => Set<Report>();
 public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
 public DbSet<ContactMessage> ContactMessages => Set<ContactMessage>();
 protected override void OnModelCreating(ModelBuilder b)
 {
  b.Entity<User>().HasIndex(x=>x.Username).IsUnique();
  b.Entity<User>().Property(x=>x.Username).HasMaxLength(50);
  b.Entity<User>().Property(x=>x.PasswordHash).HasMaxLength(512);
  b.Entity<User>().Property(x=>x.Role).HasMaxLength(20);
  b.Entity<Case>().HasIndex(x=>x.CaseNumber).IsUnique();
  b.Entity<Case>().Property(x=>x.CaseNumber).HasMaxLength(40);
  b.Entity<Case>().Property(x=>x.Title).HasMaxLength(160);
  b.Entity<Case>().Property(x=>x.Description).HasMaxLength(4000);
  b.Entity<Case>().Property(x=>x.Status).HasMaxLength(20);
  b.Entity<Case>().Property(x=>x.Priority).HasMaxLength(20);
  b.Entity<Case>().HasOne<User>().WithMany().HasForeignKey(x=>x.CreatedBy).OnDelete(DeleteBehavior.Restrict);
  b.Entity<Investigation>().HasOne<Case>().WithMany().HasForeignKey(x=>x.CaseId).OnDelete(DeleteBehavior.Restrict);
  b.Entity<Investigation>().Property(x=>x.InputValueHash).HasMaxLength(64);
  b.Entity<Investigation>().Property(x=>x.InputType).HasMaxLength(30);
  b.Entity<Finding>().HasOne<Investigation>().WithMany().HasForeignKey(x=>x.InvestigationId).OnDelete(DeleteBehavior.Restrict);
  b.Entity<Finding>().Property(x=>x.FindingType).HasMaxLength(80);
  b.Entity<Finding>().Property(x=>x.SourceUrl).HasMaxLength(2048);
  b.Entity<Evidence>().HasOne<Case>().WithMany().HasForeignKey(x=>x.CaseId).OnDelete(DeleteBehavior.Restrict);
  b.Entity<Evidence>().Property(x=>x.Sha256).HasMaxLength(64);
  b.Entity<Evidence>().Property(x=>x.OriginalName).HasMaxLength(255);
  b.Entity<Evidence>().Property(x=>x.Source).HasMaxLength(2048);
  b.Entity<Report>().HasOne<Case>().WithMany().HasForeignKey(x=>x.CaseId).OnDelete(DeleteBehavior.Restrict);
  b.Entity<AuditLog>().HasIndex(x=>x.Timestamp);
  b.Entity<ContactMessage>().Property(x=>x.Name).HasMaxLength(120);
  b.Entity<ContactMessage>().Property(x=>x.Email).HasMaxLength(254);
  b.Entity<ContactMessage>().Property(x=>x.Message).HasMaxLength(4000);
 }
}
