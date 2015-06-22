@echo off
title 修复 VAC 被屏蔽小工具 2015.06.22 EOL
color f0
cd /d %~dp0
if exist %systemroot%\system32\mode.com if exist %systemroot%\system32\ureg.dll mode con cols=80 lines=50
setlocal ENABLEDELAYEDEXPANSION&set errorlevel=&path %systemroot%\system32&ConsExt /crv 0
:: 如果命令扩展被启用，IF 会如下改变:
:: 
::     IF [/I] string1 compare-op string2 command
::     IF CMDEXTVERSION number command
::     IF DEFINED variable command
:: 
:: 其中， compare-op 可以是:
:: 
::     EQU - 等于
::     NEQ - 不等于
::     LSS - 小于
::     LEQ - 小于或等于
::     GTR - 大于
::     GEQ - 大于或等于
:: 去掉日志，执行结果显示在屏幕上 通过 errorlevel 判断
:: 检测版本，不支持 xp 5.1 
:: ConsExt.exe 改成鼠标点击操作，而不是手动输入，防止输入其他字符导致崩溃
:: 增加bcdedit检测，不存在则使用自带bcdedit，同时集成win8.1 bcdedit以防万一
:: steamservice.exe repair complete... errorlevel = 0
:: 必须以管理员权限运行，bcdedit.exe，steamservice.exe和结束进程所需
:: bcdedit 非管理员权限拒绝访问 && 找不到元素 errorlevel=1 
::                                成功完成 errorlevel = 0

:: 删除之前本批处理产生的判断 admin 权限的垃圾文件
del /f /q "%SystemRoot%\System32\BatTestUACin_SysRt*.batemp" >nul 2>nul
:SYSCHECK
:: test in vm xp
set osver=
ver|find /i "5.1" >nul && set osver=WinXP
ver|find /i "6.1" >nul && set osver=Win7
ver|find /i "6.2" >nul && set osver=Win8
ver|find /i "6.3" >nul && set osver=Win8.1

if /I "%osver%"=="WinXP" goto :NOXP
if /I "%osver%"=="" goto :UNKNOWNOS
goto :BECHECK

:BECHECK
:: test in vm xp
set be_="%SystemRoot%\System32\bcdedit.exe"
IF NOT EXIST %SystemRoot%\System32\bcdedit.exe set be_=be
::set be_=%SystemRoot%\System32\bcdedit.exe
goto :RUN

:::ADMINCHECK
::%be_% >nul
::if !errorlevel! geq 1 (
::color 4f & echo ------ 请点击[X]关闭本窗口并右键本文件点击"以管理员权限运行"
::) else (
::echo ------ 正在以管理员身份运行当前批处理 & goto :RUN
::)
::pause >nul
::exit


:RUN
cls
color f0
echo ------ 您正在使用的操作系统为： %osver%
echo.
echo                     注意
echo.
echo =================================================================
echo.
echo    ///////  安装版 Steam 运行之后强烈建议重启电脑 \\\\\\\\\\\\\\
echo.
echo    //便携版 Steam 运行后可先游戏，再次出问题请尽量不在网吧游戏\\
echo.
echo  [[[[[[首先关闭 360这类的安全软件，以防批处理出错]]]]]]]
echo             确保BIOS里面的【Secure Boot已经关闭】
echo =================================================================
echo.
echo      说明：安装版 Steam 适用于一般家用机
echo            便携版 Steam 为网吧党设置，适用于移动版 Steam
echo            删除文件系统USN日志仅限于NTFS，用前仔细看说明！
echo              -- 请  点  击  下  列  选  项 --
echo.
echo    选项：
echo           【I. 安装版 Steam 继续】
echo.
echo           【P. 便携版 Steam 继续】
echo.
echo           【F. 删除文件系统日志 】
echo.
echo           【S. 显示官方知识库文章】
echo.
echo           【E. 退         出    】
ConsExt /event
set /a xy=!errorlevel!
set /a x=%xy:~0,-3%
set /a y=%xy%-1000*%x%
if %y% equ 20 (
if %x% gtr 10 if %x% leq 35 goto :START
)
if %y% equ 22 (
if %x% gtr 10 if %x% leq 35 goto :NETCAFE
)
if %y% equ 24 (
if %x% gtr 10 if %x% leq 35 goto :DELUSN
)
if %y% equ 26 (
if %x% gtr 10 if %x% leq 35 goto :SHOWKB
)
if %y% equ 28 (
if %x% gtr 10 if %x% leq 35 goto :TERMINATE
)
goto :RUN

:START
cls
title 处理中....
color 4f
:: 确保 steam.exe 和 steamservice.exe 处于结束状态
tasklist|find /i "Steam.exe" && set rexe=1 || set rexe=0
tasklist|find /i "steamservice.exe" && set rsrv=1 || set rsrv=0
if %rexe%==1 taskkill /f /im "Steam.exe"
if %rsrv%==1 taskkill /f /im "steamservice.exe"

echo -----修复 VAC 小工具操作中...  
echo --- 【【【【    操作完成之后强烈建议重启    】】】】】】 
for /f "tokens=1,2,* " %%i in ('REG QUERY "HKEY_CURRENT_USER\Software\Valve\Steam" ^| find /i "SteamPath"') do set "RootPath=%%k" 
echo -----注册表中Steam安装目录为%RootPath%，安装盘符为%RootPath:~0,1%
::  如果获得的路径包含空格，会导致修复失败，使用引号包围路径转成字符串.
IF NOT EXIST "%RootPath%\steam.exe" goto NOSTEAM
IF NOT EXIST "%RootPath%\bin\steamservice.exe" goto NOSTEAM
echo -----清除appcache文件夹
:: 清除appcache
set /p="清除appcache文件夹..." <nul
rd /s /q "%RootPath%\appcache" >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
:: 调用:COREFIX
call :COREFIX %RootPath%
echo.
echo -----操作结束，试一下steam能否正常工作吧 
echo --- 【【【【    操作完成之后强烈建议重启    】】】】】】 

pause & break
goto :RUN

:NETCAFE
cls
color 2f
:: check if we have cscript.exe
IF NOT EXIST "%SystemRoot%\System32\cscript.exe" set cscript="%~dp0\cscript.exe"
set cscript=%SystemRoot%\System32\cscript.exe
echo     ------请在弹出的选项框寻找到 Steam.exe 所在的目录并点击确定------
echo     ------              直接点击 取消 则退出                   ------
echo       例如：优盘盘符为 X，其中有Steam 文件夹，文件夹内有 Steam.exe
echo              则选择到 X:\Steam 即可
echo set objShell = CreateObject("Shell.Application")>tmp.vbs
echo set objFolder = objShell.Namespace(^&H11^&)>>tmp.vbs
echo set objFolderItem = objFolder.Self>>tmp.vbs
echo strPath = objFolderItem.Path>>tmp.vbs
echo set objShell = CreateObject("Shell.Application")>>tmp.vbs
echo set objFolder = objShell.BrowseForFolder(0, "选择 Steam.exe 的位置 例如 E:\Steam ", 0, strPath)>>tmp.vbs
echo if objFolder is Nothing then>>tmp.vbs
echo Wscript.Quit>>tmp.vbs
echo end if>>tmp.vbs
echo set objFolderItem = objFolder.Self>>tmp.vbs
echo objPath = objFolderItem.Path>>tmp.vbs
echo Wscript.Echo objPath>>tmp.vbs
For /f "delims=" %%i in ('%cscript% /nologo tmp.vbs') do set "CAFE=%%i"
Del /f /q tmp.vbs 1>nul 2>nul
cls
if /I "!CAFE!"=="" goto :TERMINATE

tasklist|find /i "Steam.exe" && set rexe=1 || set rexe=0
tasklist|find /i "steamservice.exe" && set rsrv=1 || set rsrv=0
if %rexe%==1 taskkill /f /im "Steam.exe"
if %rsrv%==1 taskkill /f /im "steamservice.exe"
echo -----修复 VAC 批处理操作中...  
IF NOT EXIST "!CAFE!\steam.exe" goto NOSTEAM
IF NOT EXIST "!CAFE!\bin\steamservice.exe" goto NOSTEAM
echo -----清除appcache文件夹
:: 清除appcache
set /p="清除appcache文件夹..." <nul
rd /s /q "!CAFE!\appcache" >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
:: 调用:COREFIX
call :COREFIX !CAFE!
echo -----操作结束，试一下steam能否正常工作吧 
pause & break
goto :RUN

:DELUSN
cls
color 1f
:: 管理更新序列号 (USN) 更改日志，该日志提供了对卷中所有文件所做更改的永久性记录
:: 要查询驱动器 C 上卷的 USN 数据，请键入： fsutil usn queryjournal C:  Note: C: will be the drive letter for your main HDD.
:: 要删除驱动器 C 上活动的 USN 更改日志，请键入： fsutil usn deletejournal /D C:
:: check if we have cscript.exe
IF NOT EXIST "%SystemRoot%\System32\cscript.exe" set cscript="%~dp0\cscript.exe"
set cscript=%SystemRoot%\System32\cscript.exe
echo     ------请在弹出的选项框寻找到主磁盘驱动器盘符并点击确定------
echo     ------              直接点击 取消 则退出                   ------
echo       注意：如果主分区不是C的话需要选择主分区，否则选C盘就行了，不用点
echo              下面的文件或者文件夹，不确定的也选C盘
echo set objShell = CreateObject("Shell.Application")>tmp.vbs
echo set objFolder = objShell.Namespace(^&H11^&)>>tmp.vbs
echo set objFolderItem = objFolder.Self>>tmp.vbs
echo strPath = objFolderItem.Path>>tmp.vbs
echo set objShell = CreateObject("Shell.Application")>>tmp.vbs
echo set objFolder = objShell.BrowseForFolder(0, "选择 Steam.exe 的驱动器 例如 E:\", 0, strPath)>>tmp.vbs
echo if objFolder is Nothing then>>tmp.vbs
echo Wscript.Quit>>tmp.vbs
echo end if>>tmp.vbs
echo set objFolderItem = objFolder.Self>>tmp.vbs
echo objPath = objFolderItem.Path>>tmp.vbs
echo Wscript.Echo objPath>>tmp.vbs
For /f "delims=" %%i in ('%cscript% /nologo tmp.vbs') do set "PATH1=%%i"
Del /f /q tmp.vbs 1>nul 2>nul
cls
if /I "!PATH1!"=="" goto :TERMINATE
:: we need drive letter, pick 1st char
set DRIVE_LETTER=%PATH1:~0,1%

echo ------删除USN更改日志
set /p="删除%DRIVE_LETTER%盘USN更改日志..." <nul
fsutil usn deletejournal /n %DRIVE_LETTER%: >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)

pause & break
goto :RUN

:SHOWKB
cls
color f0
echo 官方知识库英文修复教程如下，如果没有打开IE，请手动输入链接查看
echo 官方链接： https://support.steampowered.com/kb_article.php?ref=2117-ilzv-2837
echo 可能的冲突软件列表： https://support.steampowered.com/kb_article.php?ref=9828-SFLZ-9289
start iexplore.exe https://support.steampowered.com/kb_article.php?ref=2117-ilzv-2837
start iexplore.exe https://support.steampowered.com/kb_article.php?ref=9828-SFLZ-9289
pause & break
cls
goto :RUN

:NOSTEAM
cls
color 3f
echo -----未检测到安装版 Steam 或 便携版 Steam 选择路径不对
echo -----请重新安装 Steam 或 重新选择路径！
pause & break
goto :RUN

:NOXP
cls
color 3f
echo ----- 一般来说 WinXP 不会出问题，本工具不支持 WinXP 系统
echo ----- 请使用 Win 7 及以上版本系统！
pause & break
goto :RUN

:UNKNOWNOS
cls
color 3f
echo ----- 未知操作系统，本工具的修复效果未知
echo ----- 请使用 Win 7 及以上版本系统！
pause & break
goto :RUN

:TERMINATE
cls
color 3f
echo -----修复 VAC 小工具被用户终止！
pause & break
exit

:COREFIX
:: 先配置Steam本身的服务，之后配置其余必要信息
:: 配置基础服务并开启必须开启的服务
:: Base Fitering Engine
:: Windows Firewall
:: Telephony 
:: Remote Access Connection Manager 
:: Network Connections 
:: Remote Procedure Call (RPC) Locator
:: Steam Client Service
:: 最后进行Steam的DEP相关修复操作
echo -----Steam服务修复
:: 因为网吧刚开始没有steam安装，必须要先安装一下服务
::  可能有的网吧预先已经安装steam，我们先卸载一遍在安装，以防万一
set /p="卸载 Steam 服务..." <nul
"%1\bin\steamservice.exe" /uninstall >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="安装 Steam 服务..." <nul
"%1\bin\steamservice.exe" /install >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="修复 Steam 服务..." <nul
"%1\bin\steamservice.exe" /repair >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
echo -----配置服务项
set /p="配置Base Fitering Engine启动模式..." <nul
sc config BFE start= auto >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="启动Base Fitering Engine..." <nul
sc start BFE >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
::   设置防火墙服务，可能会有作用
::  等号和选项之间需要空格隔开，根据反馈，部分 win7 提示
set /p="配置Windows Firewall启动模式..." <nul
sc config MpsSvc start= auto >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="启动Windows Firewall..." <nul
sc start MpsSvc >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="配置Telephony 启动模式..." <nul
sc config TapiSrv start= demand >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="配置Remote Access Connection Manager启动模式..." <nul
sc config RasMan start= demand >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="配置Network Connections启动模式..." <nul
sc config Netman start= demand >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="配置Remote Procedure Call (RPC) Locator启动模式..." <nul
sc config RpcLocator start= demand >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="配置Steam Client Service启动模式..." <nul
sc config "Steam Client Service" start= demand >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
::  修改DEP模式
::  目前不应该设置 nx 值，原来可以使用OptIn，Alwayson会在win8.1 x64出问题，比如迅雷和完美解码

::  官方说明中，需要每个命令执行后就重启，我们统一执行之后再重启
echo -----Steam相关设置
set /p="删除 nointegritychecks 值..." <nul
%be_% /deletevalue nointegritychecks >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="删除 loadoptions 值..." <nul
%be_% /deletevalue loadoptions >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="关闭内核调试模式..." <nul
%be_% /debug off >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="删除 nx 值..." <nul
%be_% /deletevalue nx >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.

