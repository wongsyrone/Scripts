@echo off
cd /D %~dp0
echo    will remove all content in apks/ folder....
echo -----------Press any key
echo.
pause & break

del apks\*.apk /f /q 2>nul
::copy nul clean.tmp
pause & break