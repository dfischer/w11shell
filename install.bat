@echo off
:: W11Shell Bulk Archive Extraction - Installation Script
:: Run this script as Administrator

echo W11Shell Bulk Archive Extraction - Installation
echo ================================================

:: Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
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
    echo Please ensure Nilesoft Shell is properly installed
    pause
    exit /b 1
)

:found
echo Found Nilesoft Shell at: %NILESOFT_DIR%

:: Copy configuration files
echo.
echo Installing configuration files...

:: Copy shell.nss
if exist "%NILESOFT_DIR%\shell.nss" (
    echo Creating backup of existing shell.nss...
    copy "%NILESOFT_DIR%\shell.nss" "%NILESOFT_DIR%\shell.nss.backup" >nul
)

echo Copying shell.nss configuration...
copy "%SCRIPT_DIR%shell.nss" "%NILESOFT_DIR%\" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy shell.nss
    pause
    exit /b 1
)

:: Copy scripts directory
echo Copying extraction scripts...
if exist "%NILESOFT_DIR%\scripts" (
    echo Creating backup of existing scripts directory...
    if exist "%NILESOFT_DIR%\scripts.backup" rmdir /s /q "%NILESOFT_DIR%\scripts.backup"
    move "%NILESOFT_DIR%\scripts" "%NILESOFT_DIR%\scripts.backup" >nul
)

xcopy "%SCRIPT_DIR%scripts" "%NILESOFT_DIR%\scripts" /s /i /y >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy scripts directory
    pause
    exit /b 1
)

:: Restart Windows Explorer
echo.
echo Restarting Windows Explorer to apply changes...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo Installation completed successfully!
echo.
echo Next steps:
echo 1. Right-click on any archive file to test the context menu
echo 2. Look for "Extract Here (Auto-folder)" or bulk extraction options
echo 3. For multiple files, select them and use "Extract Archives (Bulk)"
echo.
echo If you don't see the context menu options:
echo 1. Ensure Nilesoft Shell is properly registered
echo 2. Try logging out and back in
echo 3. Check the troubleshooting section in README.md
echo.

pause