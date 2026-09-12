using System.Text;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using OSINTPlatform.API.Middleware;
using OSINTPlatform.Core.Interfaces;
using OSINTPlatform.Infrastructure.Data;
using OSINTPlatform.Infrastructure.Forensics;
using OSINTPlatform.Infrastructure.OSINT;
using OSINTPlatform.Infrastructure.Repositories;
using OSINTPlatform.Infrastructure.Reports;
using OSINTPlatform.Infrastructure.Security;

if(args.Contains("--export-schema")) {
 using var schemaDb=new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseSqlServer("Server=localhost;Database=unused;Trusted_Connection=True").Options);
 Console.Write(schemaDb.Database.GenerateCreateScript());return;
}
var builder=WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.Local.json",optional:true,reloadOnChange:false).AddEnvironmentVariables();
var key=builder.Configuration["Jwt:Key"];
if(string.IsNullOrWhiteSpace(key) || Encoding.UTF8.GetByteCount(key)<32) throw new InvalidOperationException("Configure Jwt:Key with at least 32 random bytes using user-secrets or Jwt__Key.");
var connection=builder.Configuration.GetConnectionString("DefaultConnection");
if(string.IsNullOrWhiteSpace(connection)) throw new InvalidOperationException("Configure ConnectionStrings:DefaultConnection for SQL Server.");
builder.Configuration["Storage:Root"]=Path.GetFullPath(builder.Configuration["Storage:Root"] ?? "../../",builder.Environment.ContentRootPath);
builder.Services.AddDbContext<ApplicationDbContext>(o=>o.UseSqlServer(connection));
builder.Services.AddControllers();
builder.Services.AddDataProtection().PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(builder.Environment.ContentRootPath,".data-protection"))).SetApplicationName("OSINTPlatform");
builder.Services.Configure<FormOptions>(o=>o.MultipartBodyLengthLimit=FileValidationService.MaxBytes+65536);
builder.WebHost.ConfigureKestrel(o=>o.Limits.MaxRequestBodySize=FileValidationService.MaxBytes+65536);
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(o=>o.TokenValidationParameters=new TokenValidationParameters {
 ValidateIssuer=true,ValidateAudience=true,ValidateLifetime=true,ValidateIssuerSigningKey=true,
 ValidIssuer=builder.Configuration["Jwt:Issuer"],ValidAudience=builder.Configuration["Jwt:Audience"],
 IssuerSigningKey=new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),ClockSkew=TimeSpan.FromSeconds(30)
});
builder.Services.AddAuthorization();
builder.Services.AddPlatformRateLimits();
builder.Services.AddCors(o=>o.AddDefaultPolicy(p=>p.WithOrigins(builder.Configuration.GetSection("Cors:Origins").Get<string[]>() ?? []).AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddScoped<ICaseService,CaseRepository>();
builder.Services.AddScoped<IAuthService,AuthorizationService>();
builder.Services.AddScoped<UserRepository>();
builder.Services.AddScoped<FindingRepository>();
builder.Services.AddScoped<IEvidenceService,EvidenceRepository>();
builder.Services.AddScoped<IReportService,PdfReportService>();
builder.Services.AddSingleton<PasswordService>();
builder.Services.AddSingleton<JwtService>();
builder.Services.AddSingleton<FileValidationService>();
builder.Services.AddSingleton<EvidenceIntegrityService>();
builder.Services.AddSingleton<OCRService>();
builder.Services.AddSingleton<IImageForensicsService,ImageMetadataService>();
builder.Services.AddHttpClient<IPhoneOSINTService,PhoneOSINTService>();
builder.Services.AddScoped<IEmailOSINTService,EmailOSINTService>();
builder.Services.AddScoped<IUsernameOSINTService,UsernameOSINTService>();
builder.Services.AddScoped<IDomainOSINTService,DomainOSINTService>();
builder.Services.AddScoped<IIPOSINTService,IPOSINTService>();
var app=builder.Build();
if(!app.Environment.IsDevelopment()) { app.UseHsts(); app.UseHttpsRedirection(); }
app.Use(async(c,next)=> { c.Response.Headers.XContentTypeOptions="nosniff";c.Response.Headers.CacheControl="no-store";await next(); });
app.UseCors();
app.UseAuthentication();
app.UseMiddleware<AuditMiddleware>();
app.UseMiddleware<ExceptionMiddleware>();
app.UseRateLimiter();
app.UseAuthorization();
app.MapControllers();
app.MapGet("/health",()=>Results.Ok(new { status="ok",service="OSINTPlatform.API" }));
if(builder.Configuration.GetValue<bool>("Database:Initialize")) {
 using var scope=app.Services.CreateScope();
 await DbInitializer.InitializeAsync(scope.ServiceProvider.GetRequiredService<ApplicationDbContext>());
}
app.Run();
public partial class Program { }
