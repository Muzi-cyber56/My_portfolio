param([string]$SqlServer = '.\SQLEXPRESS')
$ErrorActionPreference = 'Stop'
$taskApi = Join-Path $PSScriptRoot '../portfolio-api/OSINTPlatform.API'
$taskLocal = Join-Path $taskApi 'appsettings.Local.json'
if (-not (Test-Path -LiteralPath $taskLocal)) {
  $taskBytes = New-Object byte[] 48
  $taskRng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  $taskRng.GetBytes($taskBytes)
  $taskRng.Dispose()
  @{
    Jwt = @{ Key = [Convert]::ToBase64String($taskBytes) }
    ConnectionStrings = @{ DefaultConnection = "Server=$SqlServer;Database=OSINTPlatform;Trusted_Connection=True;Encrypt=True;TrustServerCertificate=True" }
    Forensics = @{ TesseractPath = '' }
  } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $taskLocal -Encoding UTF8
}
$taskPreviousEnvironment = $env:ASPNETCORE_ENVIRONMENT
try {
  $env:ASPNETCORE_ENVIRONMENT = 'Development'
  Push-Location $taskApi
  dotnet run --no-launch-profile --urls http://localhost:5240
  if ($LASTEXITCODE -ne 0) { throw 'Backend did not start. Check SQL Server and local settings.' }
} finally {
  Pop-Location
  $env:ASPNETCORE_ENVIRONMENT = $taskPreviousEnvironment
}
