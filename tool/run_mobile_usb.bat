@echo off
setlocal

set "ADB=C:\sdk\platform-tools\adb.exe"

if not exist "%ADB%" (
  echo adb was not found at %ADB%
  echo Update this script if your Android SDK is installed in another path.
  exit /b 1
)

"%ADB%" devices
"%ADB%" reverse tcp:3000 tcp:3000

flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
