@echo off
setlocal
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoLogo -File "%~dp0adventure.ps1"
echo.
pause
