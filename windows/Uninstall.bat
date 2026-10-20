@echo off
rem Removes the Core Theory screensaver for the current user.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
pause
