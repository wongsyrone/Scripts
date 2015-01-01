@echo off
cd /D %~dp0
echo  Caution:  Must use ANSI encoding to function well on Windows. (This is dedicated for Windows BTW
echo  This script only support installing apks in apks/ folder, which are exported using Wandoujia
echo  You must clean up Chinese characters to make it work. 
echo  In general, file names are seperated into three or four parts by underline(_), and the first part contains Chinese chars.
echo  You can continue the procedure if have confirmed there are no Chinese chars.
echo -----------Press any key
echo.
pause & break
if not exist apks\*.apk goto :bye
setlocal enableDelayedExpansion
:: terminate processes may interfere our ADB 
taskkill /f /im "wandoujia2.exe" 2>nul
taskkill /f /im "wandoujia_helper.exe" 2>nul
taskkill /f /im "tadb.exe" 2>nul
:: only for Apps export via Wandoujia
if exist apks\no_chinese_char goto :go

:dealwithch
:: Divided by three parts and drop the first part
for /f "tokens=1,2,3* delims=_" %%a in ('dir /a /b apks\*.apk') DO (
cd apks
ren "%%a_%%b_%%c" "%%b_%%c" 2>nul
cd ..
)
:: Divided by four parts and drop the first part
for /f "tokens=1,2,3,4* delims=_" %%e in ('dir /a /b apks\*.apk') DO (
cd apks
ren "%%e_%%f_%%g_%%h" "%%f_%%g_%%h" 2>nul
cd ..
)
copy nul apks\no_chinese_char 2>nul
goto :go

:go
echo  Preparing ADB
data\adb.exe kill-server
ping -n 3 127.0.0.1 >nul
data\adb.exe start-server
ping -n 3 127.0.0.1 >nul
data\adb.exe devices
echo.
echo  Start install all apks, and please make sure the file name doesnt contain Chinese Chars....
pause & break

for /f "delims=" %%i in ('dir /s /b apks\*.apk') DO (
data\adb.exe install -r "%%i"
)

data\adb.exe shell su -c "rm /data/local/tmp/*.apk"
pause & break
exit

:bye
cls
echo  no apk files in apks/ folder
pause & break
exit
