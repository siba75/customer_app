param(
  [string]$DeviceId = "",
  [int]$ApiPort = 3000,
  [string]$ApiBaseUrl = ""
)

$ErrorActionPreference = "Stop"

$adbCandidates = @(
  "$env:ANDROID_HOME\platform-tools\adb.exe",
  "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
  "C:\sdk\platform-tools\adb.exe",
  "adb.exe"
)

$adb = $adbCandidates | Where-Object { $_ -and (Get-Command $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1

if (-not $adb) {
  throw "adb.exe was not found. Install Android platform-tools or add adb to PATH."
}

if (-not $ApiBaseUrl) {
  $ApiBaseUrl = "http://localhost:$ApiPort"
}

Write-Host "Using API: $ApiBaseUrl"
Write-Host "Configuring adb reverse tcp:$ApiPort -> tcp:$ApiPort"

& $adb reverse "tcp:$ApiPort" "tcp:$ApiPort"

$flutterArgs = @(
  "run",
  "--dart-define=API_BASE_URL=$ApiBaseUrl"
)

if ($DeviceId) {
  $flutterArgs += @("-d", $DeviceId)
}

& flutter @flutterArgs
