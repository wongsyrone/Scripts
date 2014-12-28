@echo off
cd /D %~dp0
echo -----------Press any key
echo.
pause & break
echo  Preparing ADB
data\adb.exe kill-server
ping -n 3 127.0.0.1 >nul
data\adb.exe start-server
ping -n 3 127.0.0.1 >nul
data\adb.exe devices
echo.
echo  Start push rom-zip folder files....
for /f "delims=" %%i in ('dir /s /b rom-zip\*.zip') DO (
:: target path need verify
data\adb.exe push -p "rom-zip\%%i" /storage/sdcard0
)

::copy nul clean.tmp
pause & break