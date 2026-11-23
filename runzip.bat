@echo off
cd /d "%~dp0"
set "PATH=C:\Program Files\nodejs;%PATH%"

echo.
echo  Building the site...
call npm.cmd run build
if errorlevel 1 (
  echo.
  echo  Build failed. The zip was not created.
  pause
  exit /b 1
)

echo.
echo  Creating the cPanel zip...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0runzip.ps1"
if errorlevel 1 (
  echo.
  echo  Zip failed. If mojdeweb-cpanel.zip is open, close it and try again.
  pause
  exit /b 1
)

echo.
echo  Done. The zip is on your Desktop:
echo  %USERPROFILE%\Desktop\mojdeweb-cpanel.zip
echo.
pause
