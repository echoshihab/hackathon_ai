@echo off
echo Setting up CCS Backend...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup-backend.ps1"
echo Done! Check for errors above.
pause
