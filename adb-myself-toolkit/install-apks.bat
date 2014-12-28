@echo off
cd /D %~dp0
echo  只用于豌豆荚导出的apk的自动安装，保存在apks文件夹中
echo  必须去除中文名称，已下划线为分隔符
echo  分成三段，去除第一段的描述，如果有例外情况需要手工修改
echo  确认没有中文就可以安装了
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
