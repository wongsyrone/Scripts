@echo off
title 傻瓜化解决 VAC 被屏蔽的批处理 2014.11.12
color f0
cd /d %~dp0
if exist %systemroot%\system32\mode.com if exist %systemroot%\system32\ureg.dll mode con cols=80 lines=32
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
if /I "%osver%"=="" goto :NOSUPPORT
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
echo.
echo =================================================================
echo.
echo      说明：安装版 Steam 适用于一般家用机
echo            便携版 Steam 为网吧党设置，适用于移动版 Steam
echo              -- 请  点  击  下  列  选  项 --
echo.
echo    选项：
echo           【I. 安装版 Steam 继续】
echo.
echo           【P. 便携版 Steam 继续】
echo.
echo           【S. 显示官方知识库文章】
echo.
echo           【E. 退         出    】
:: 返回值：如果是键盘按下事件，返回的是各键对应的虚拟键值。如果是鼠标左键点击，返回值为：鼠标x坐标*1000+y+1000。
:: I...73 P...80 S...83 E...69
ConsExt /event
set /a xy=!errorlevel!
:: mouse support
set /a x=%xy:~0,-3%
set /a y=%xy%-1000*%x%
if %y% equ 19 (
if %x% gtr 10 if %x% leq 35 goto :START
)
if %y% equ 21 (
if %x% gtr 10 if %x% leq 35 goto :NETCAFE
)
if %y% equ 23 (
if %x% gtr 10 if %x% leq 35 goto :SHOWKB
)
if %y% equ 25 (
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

echo -----修复 VAC 批处理操作中...  
echo --- 【【【【    操作完成之后强烈建议重启    】】】】】】 
for /f "tokens=1,2,* " %%i in ('REG QUERY "HKEY_CURRENT_USER\Software\Valve\Steam" ^| find /i "SteamPath"') do set "RootPath=%%k" 
echo -----注册表中Steam安装目录为%RootPath%，安装盘符为%RootPath:~0,1%
::  如果获得的路径包含空格，会导致修复失败，使用引号包围路径转成字符串.
IF NOT EXIST "%RootPath%\steam.exe" goto NOSTEAM
IF NOT EXIST "%RootPath%\bin\steamservice.exe" goto NOSTEAM
::   设置防火墙服务，可能会有作用
::  等号和选项之间需要空格隔开，根据反馈，部分 win7 提示
set /p="配置防火墙启动模式..." <nul
sc config MpsSvc start= auto >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL!
)
echo.
set /p="启动防火墙..." <nul
sc start MpsSvc >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
::  修改DEP模式
::  目前不应该设置 nx 值，原来可以使用OptIn，Alwayson会在win8.1 x64出问题，比如迅雷和完美解码

::  官方说明中，需要每个命令执行后就重启，我们统一执行之后再重启
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
set /p="修复 Steam 服务..." <nul
"!RootPath!\bin\steamservice.exe" /repair >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
echo -----操作结束，试一下steam能否正常工作吧 
echo --- 【【【【    操作完成之后强烈建议重启    】】】】】】 

pause & break
exit

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
set /p="配置防火墙启动模式..." <nul
sc config MpsSvc start= auto >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="启动防火墙..." <nul
sc start MpsSvc >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
:: 因为网吧刚开始没有steam安装，必须要先安装一下服务
::  可能有的网吧预先已经安装steam，我们先卸载一遍在安装，以防万一
set /p="卸载 Steam 服务..." <nul
"!CAFE!\bin\steamservice.exe" /uninstall >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="安装 Steam 服务..." <nul
"!CAFE!\bin\steamservice.exe" /install >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
set /p="修复 Steam 服务..." <nul
"!CAFE!\bin\steamservice.exe" /repair >nul 2>nul
if !errorlevel! equ 0 (
echo OK!
) else (
echo FAIL! 
)
echo.
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
echo -----操作结束，试一下steam能否正常工作吧 
pause & break
exit

:SHOWKB
cls
color f0
echo 官方知识库英文修复教程如下，如果没有打开IE，请手动输入链接查看
echo 官方链接： https://support.steampowered.com/kb_article.php?ref=2117-ilzv-2837
start iexplore.exe https://support.steampowered.com/kb_article.php?ref=2117-ilzv-2837
pause & break
cls
goto :RUN

:NOSTEAM
cls
color 3f
echo -----未检测到安装版 Steam 或 便携版 Steam 选择路径不对，请重新安装 Steam 或 重新选择路径！
pause & break
exit


:NOXP
cls
color 3f
echo -----不支持 WinXP 系统，请使用 Win 7 及以上版本系统！
pause & break
exit

:NOSUPPORT
cls
color 3f
echo -----不支持的操作系统，此工具的修复效果未知！
echo -----请在 csgo 百度贴吧通知作者
pause & break
exit

:TERMINATE
cls
color 3f
echo -----修复 VAC 批处理操作中...  
echo -----用户终止！  
pause & break
exit


::    官方知识库修复教程
::    Official Repair Instructions
::  
:: Repair the Steam Service
:: This may also indicate a Steam Service failure.  Please try repairing the Steam Service:
:: Exit Steam.
:: Click Start > Run (Windows Key + R)
:: Type the following command:
:: 
:: "C:\Program Files (x86)\Steam\bin\SteamService.exe" /repair 
:: 
:: (If you have installed Steam to another path, please replace C:\Program Files (x86)\Steam with the correct path.)
:: 
:: This command requires administrator privileges and may take a few minutes.
:: Launch Steam and test the issue again. 
:: Enable Kernel Integrity
:: Kernel Integrity checks must be enabled to play on VAC secured servers. To enable Kernel Integrity checks please follow the steps below:
:: Exit Steam.
:: Click the Start button, then 'All Programs', and 'Accessories'
:: Right-click on Command Prompt and click "Run as administrator..."
:: 
:: - Please note if you are running Windows 8 you will need to press Windows Key + X and select Command Prompt (Admin) 
:: 
:: In the command prompt, type the following commands and press Enter after each command:
:: 
:: bcdedit /deletevalue nointegritychecks 
:: bcdedit /deletevalue loadoptions 
::  
:: Restart your computer.
:: Launch Steam and test the issue again. 
:: Turn off Kernel Debugging
:: Kernel Debugging must be turned off to play on VAC secured servers. To turn off Kernel Debugging please follow the steps below:
:: Exit Steam.
:: Click the Start button, then 'All Programs', and 'Accessories'
:: Right-click on Command Prompt and click "Run as administrator..."
:: 
:: - Please note if you are running Windows 8 you will need to press Windows Key + X and select Command Prompt (Admin) 
:: 
:: In the command prompt, type the following command and press Enter:
:: 
:: bcdedit /debug off 
::  
:: Restart your computer.
:: Launch Steam and test the issue again. 
:: Enable DEP
:: Data Execution Prevention (DEP) must be enabled to play on VAC secured servers. To restore DEP settings to default please follow the steps below:
:: Exit Steam.
:: Click the Start button, then 'All Programs', and 'Accessories'
:: Right-click on Command Prompt and click "Run as administrator..."
:: 
:: - Please note if you are running Windows 8 you will need to press Windows Key + X and select Command Prompt (Admin) 
:: 
:: In the command prompt, type the following command and press Enter:
:: 
:: bcdedit /deletevalue nx  
::  
:: Restart your computer.
:: Launch Steam and test the issue again. 
:: Restart your computer
:: If this is a problem for you on all servers then you can try fixing this problem by exiting Steam and restarting your computer.
