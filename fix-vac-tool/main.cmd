@echo off
setlocal enabledelayedexpansion
color 1f
path %windir%\system32&set errorlevel=

set tmpfile=fix-vac.tmp
if not exist %windir%\system32\reg.exe ren reg5.exe reg.exe>nul 2>nul

dir ..\fix-vac/ad 2>nul|find /i "fix-vac">nul 2>nul
if %errorlevel% equ 0 (rd ..\fix-vac /s/q>nul 2>nul&md ..\fix-vac>nul 2>nul) else md..\fix-vac>nul 2>nul
copy /y . ..\fix-vac>nul 2>nul
set /a q=1
if %q% equ 1 (
	reg add HKCU\Console\%%SystemRoot%%_system32_cmd.exe /f >nul 2>nul
	reg add HKCU\Console\%%SystemRoot%%_system32_cmd.exe /v QuickEdit /t REG_DWORD /d 0 /f >nul 2>nul)
del %tmpfile%>nul 2>nul
cd..\fix-vac
if %q% equ 1 (start cmd /c go.cmd) else go.cmd
exit