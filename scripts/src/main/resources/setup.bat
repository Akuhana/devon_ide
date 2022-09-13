@echo off
if NOT "%DEVON_IDE_TRACE%"=="" echo on

Set _fBGreen=[92m
Set _RESET=[0m

IF NOT %1.==_isNew. echo %PSModulePath% | findstr %USERPROFILE% >NUL
IF NOT %1.==_isNew. IF %ERRORLEVEL% EQU 0 start "CMD window" "%~f0" _isNew & goto :EOF
echo Running from cmd.exe...

pushd %~dp0
echo Setting up your devonfw-ide in %CD%
call scripts\devon.bat ide setup %*
reg import system/windows/cmd/devon-cmd.reg
reg import system/windows/power-shell/devon-power-shell.reg

dir %USERPROFILE%\AppData\Local\Microsoft\WindowsApps\wt.exe >NUL 2>NUL
if "%ERRORLEVEL%" == "0" (
  reg import system/windows/windows-terminal/devon-wt-cmd.reg
  reg import system/windows/windows-terminal/devon-wt-gitbash.reg
  reg import system/windows/windows-terminal/devon-wt-ps.reg
)

for /F "usebackq tokens=2*" %%O in (`call "%SystemRoot%"\system32\reg.exe query "HKLM\Software\Cygwin\setup" /v "rootdir" 2^>nul ^| "%SystemRoot%\system32\findstr.exe" REG_SZ`) do set CYGWIN_HOME=%%P
if exist "%CYGWIN_HOME%\bin\bash.exe" (
  reg import system/windows/cygwin/devon-cygwin.reg
  "%CYGWIN_HOME%\bin\bash.exe" -l -c "cd \"%CD%\";./scripts/devon"
)

echo %_fBGreen%Setup of devonfw-ide completed%_RESET%
if not "%1%" == "-b" (
  pause
)

popd