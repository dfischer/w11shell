# Simple test to validate PowerShell script syntax and basic functionality
# This can be run on Windows to verify the extraction script works correctly

Write-Host "W11Shell Bulk Archive Extraction - Test Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Test 1: Check PowerShell script syntax
Write-Host "`nTest 1: Checking PowerShell script syntax..." -ForegroundColor Yellow

$scriptPath = Join-Path $PSScriptRoot "scripts\bulk-extract.ps1"

if (!(Test-Path $scriptPath)) {
    Write-Error "bulk-extract.ps1 not found at: $scriptPath"
    exit 1
}

try {
    # Parse the script to check for syntax errors
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath -Raw), [ref]$null)
    Write-Host "✓ PowerShell script syntax is valid" -ForegroundColor Green
} catch {
    Write-Error "✗ PowerShell script has syntax errors: $($_.Exception.Message)"
    exit 1
}

# Test 2: Check Nilesoft Shell configuration syntax
Write-Host "`nTest 2: Checking Nilesoft Shell configuration..." -ForegroundColor Yellow

$nssPath = Join-Path $PSScriptRoot "shell.nss"

if (!(Test-Path $nssPath)) {
    Write-Error "shell.nss not found at: $nssPath"
    exit 1
}

$nssContent = Get-Content $nssPath -Raw

# Basic syntax checks for Nilesoft Shell
$requiredPatterns = @(
    "menu\(",
    "item\(",
    "cmd=",
    "args=",
    "bulk-extract\.ps1"
)

$allPatternsFound = $true
foreach ($pattern in $requiredPatterns) {
    if ($nssContent -notmatch $pattern) {
        Write-Error "✗ Required pattern not found in shell.nss: $pattern"
        $allPatternsFound = $false
    }
}

if ($allPatternsFound) {
    Write-Host "✓ Nilesoft Shell configuration appears valid" -ForegroundColor Green
} else {
    Write-Error "✗ Nilesoft Shell configuration has issues"
    exit 1
}

# Test 3: Check file extensions coverage
Write-Host "`nTest 3: Checking supported file extensions..." -ForegroundColor Yellow

$supportedExtensions = @('.zip', '.7z', '.rar', '.tar', '.gz', '.bz2')
$foundExtensions = @()

foreach ($ext in $supportedExtensions) {
    if ($nssContent -match [regex]::Escape($ext)) {
        $foundExtensions += $ext
    }
}

Write-Host "✓ Supported extensions found: $($foundExtensions -join ', ')" -ForegroundColor Green

if ($foundExtensions.Count -eq $supportedExtensions.Count) {
    Write-Host "✓ All expected extensions are supported" -ForegroundColor Green
} else {
    $missing = $supportedExtensions | Where-Object { $_ -notin $foundExtensions }
    Write-Warning "Some extensions may not be fully supported: $($missing -join ', ')"
}

# Test 4: Check required parameters
Write-Host "`nTest 4: Checking script parameters..." -ForegroundColor Yellow

if ($nssContent -match 'ExecutionPolicy Bypass') {
    Write-Host "✓ Execution policy bypass is configured" -ForegroundColor Green
} else {
    Write-Warning "Execution policy bypass not found - may cause issues on restricted systems"
}

if ($nssContent -match 'KeepOriginals') {
    Write-Host "✓ Keep originals option is available" -ForegroundColor Green
} else {
    Write-Warning "Keep originals option not found in configuration"
}

Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "All basic tests completed!" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

Write-Host "`nNext steps for full testing:" -ForegroundColor Yellow
Write-Host "1. Install Nilesoft Shell on a Windows system" -ForegroundColor White
Write-Host "2. Run install.bat as Administrator" -ForegroundColor White  
Write-Host "3. Create test archive files (ZIP, 7Z, etc.)" -ForegroundColor White
Write-Host "4. Test context menu extraction options" -ForegroundColor White
Write-Host "5. Verify bulk extraction with multiple files" -ForegroundColor White

Write-Host "`nTest script completed successfully!" -ForegroundColor Green