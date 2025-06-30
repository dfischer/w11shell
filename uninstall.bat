@echo off
:: W11Shell Bulk Archive Extraction - Uninstall Script
:: Run this script as Administrator

echo W11Shell Bulk Archive Extraction - Uninstall
echo ==============================================

:: Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

set "NILESOFT_DIR="

:: Try to find Nilesoft Shell installation
echo Looking for Nilesoft Shell installation...

:: Check common installation paths
if exist "C:\Program Files\Nilesoft Shell\shell.exe" (
    set "NILESOFT_DIR=C:\Program Files\Nilesoft Shell"
    goto :found
)

if exist "C:\Program Files (x86)\Nilesoft Shell\shell.exe" (
    set "NILESOFT_DIR=C:\Program Files (x86)\Nilesoft Shell"
    goto :found
)

if exist "%USERPROFILE%\Nilesoft Shell\shell.exe" (
    set "NILESOFT_DIR=%USERPROFILE%\Nilesoft Shell"
    goto :found
)

:: Manual path input
echo Nilesoft Shell not found in common locations.
echo Please enter the full path to your Nilesoft Shell installation directory:
set /p NILESOFT_DIR="Path: "

if not exist "%NILESOFT_DIR%\shell.exe" (
    echo ERROR: shell.exe not found in specified directory
    pause
    exit /b 1
)

:found
echo Found Nilesoft Shell at: %NILESOFT_DIR%

:: Remove configuration files
echo.
echo Removing W11Shell configuration files...

:: Remove scripts directory
if exist "%NILESOFT_DIR%\scripts" (
    echo Removing scripts directory...
    rmdir /s /q "%NILESOFT_DIR%\scripts"
)

:: Restore backup if it exists
if exist "%NILESOFT_DIR%\shell.nss.backup" (
    echo Restoring original shell.nss configuration...
    move "%NILESOFT_DIR%\shell.nss.backup" "%NILESOFT_DIR%\shell.nss" >nul
) else (
    echo Removing shell.nss configuration...
    if exist "%NILESOFT_DIR%\shell.nss" del "%NILESOFT_DIR%\shell.nss"
)

:: Restore scripts backup if it exists
if exist "%NILESOFT_DIR%\scripts.backup" (
    echo Restoring original scripts directory...
    move "%NILESOFT_DIR%\scripts.backup" "%NILESOFT_DIR%\scripts" >nul
)

:: Restart Windows Explorer
echo.
echo Restarting Windows Explorer to apply changes...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo Uninstall completed successfully!
echo The W11Shell bulk archive extraction has been removed.
echo.

pause