@echo off
cd /D %~dp0
echo -----------Press any key
echo.
pause & break
:: terminate processes may interfere our ADB 
taskkill /f /im "wandoujia2.exe" 2>nul
taskkill /f /im "wandoujia_helper.exe" 2>nul
taskkill /f /im "tadb.exe" 2>nul
echo  Preparing ADB
data\adb.exe kill-server
ping -n 3 127.0.0.1 >nul
data\adb.exe start-server
ping -n 3 127.0.0.1 >nul
data\adb.exe devices
echo.
echo  Start push rom-zip folder files....
for /f "delims=" %%i in ('dir /s /b rom-zip\*.zip') DO (
:: target path:  
:: /sdcard ... internal storage( /storage/sdcard0 )
:: /extSdCard ... external SD card( /storage/sdcard1 )
:: all are soft-linked to /storage folder
data\adb.exe push -p "%%i" /storage/sdcard1
)

::copy nul clean.tmp
pause & break
