param([string]$Device='chrome',[string]$ApiBaseUrl='http://localhost:5240')
$ErrorActionPreference='Stop'
$taskFlutter=Get-Command flutter -ErrorAction SilentlyContinue
if ($taskFlutter) { $taskFlutterPath=$taskFlutter.Source }
else {
 $taskFlutterPath=Join-Path $env:USERPROFILE 'development/flutter/bin/flutter.bat'
 if (-not (Test-Path -LiteralPath $taskFlutterPath)) { throw 'Install Flutter SDK and add its bin directory to PATH.' }
}
Push-Location (Join-Path $PSScriptRoot '../mobile_app')
try {
 & $taskFlutterPath pub get
 if ($LASTEXITCODE -ne 0) { throw 'Flutter package restore failed.' }
if ($Device -in @('chrome','edge')) {
  Write-Host 'Starting Flutter web-server (avoids Chrome DWDS/WebSocket errors). Open http://localhost:8081 manually.'
  & $taskFlutterPath run -d web-server --web-port=8081 "--dart-define=API_BASE_URL=$ApiBaseUrl"
} elseif ($Device -eq 'web-server') {
  & $taskFlutterPath run -d web-server --web-port=8081 "--dart-define=API_BASE_URL=$ApiBaseUrl"
} else { & $taskFlutterPath run -d $Device "--dart-define=API_BASE_URL=$ApiBaseUrl" }
} finally { Pop-Location }
