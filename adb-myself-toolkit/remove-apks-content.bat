@echo off
cd /D %~dp0
echo    will remove all content in apks/ folder....
echo -----------Press any key
echo.
pause & break
if not exist apks\*.apk goto :bye
del apks\*.apk /f /q 2>nul
del apks\no_chinese_char /f /q 2>nul
::copy nul clean.tmp
pause & break

:bye
cls
echo  no apk files in apks/ folder
pause & break
exit
