# W11Shell Configuration Examples
# Copy and modify these examples to customize your setup

## Example 1: Custom file extensions
Add support for additional archive formats by modifying the file extension check in shell.nss:

```javascript
// Original line:
where=sel.count>0 and (sel.files.any(file.ext=='.zip' or file.ext=='.rar' or file.ext=='.7z' or file.ext=='.tar' or file.ext=='.gz' or file.ext=='.bz2'))

// Add .tar.gz and .tgz support:
where=sel.count>0 and (sel.files.any(file.ext=='.zip' or file.ext=='.rar' or file.ext=='.7z' or file.ext=='.tar' or file.ext=='.gz' or file.ext=='.bz2' or file.ext=='.tar.gz' or file.ext=='.tgz'))
```

## Example 2: Custom extraction directory
Modify bulk-extract.ps1 to extract to a specific directory:

```powershell
# Add this parameter to the script
param(
    [Parameter(Mandatory=$true)]
    [string[]]$ArchiveFiles,
    
    [switch]$KeepOriginals,
    
    [string]$DestinationRoot = $null  # Add this line
)

# Then modify the destination path logic:
if ($DestinationRoot) {
    $parentDir = $DestinationRoot
} else {
    $parentDir = $fileInfo.DirectoryName
}
```

## Example 3: Different context menu text
Customize the menu items in shell.nss:

```javascript
item(title='🗜️ Extract All Archives' image=icon.archive)
{
    cmd='powershell.exe'
    args='-ExecutionPolicy Bypass -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.files@"'
    tip='Extract all selected archives and remove originals'
}

item(title='🗜️ Extract (Keep Files)' image=icon.archive)
{
    cmd='powershell.exe'
    args='-ExecutionPolicy Bypass -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.files@" -KeepOriginals'
    tip='Extract all selected archives but keep original files'
}
```

## Example 4: Integration with existing Nilesoft Shell config
If you already have a shell.nss file, add this section to it instead of replacing:

```javascript
// Add this at the end of your existing shell.nss file
import "w11shell-archives.nss"
```

Then save the W11Shell configuration as "w11shell-archives.nss" in the same directory.

## Example 5: Custom PowerShell execution
For enhanced security or custom PowerShell settings:

```javascript
item(title='Extract Archives (Bulk)' image=icon.archive)
{
    cmd='powershell.exe'
    args='-ExecutionPolicy RemoteSigned -NonInteractive -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.files@"'
    tip='Extract with RemoteSigned execution policy'
}
```

## Example 6: Logging support
Add logging to the PowerShell script by modifying the script start:

```powershell
# Add at the top of bulk-extract.ps1
$LogFile = Join-Path $env:TEMP "w11shell-extraction.log"
Start-Transcript -Path $LogFile -Append

# Add at the end of the script
Stop-Transcript
```

## Example 7: Custom 7-Zip path
If 7-Zip is installed in a non-standard location:

```powershell
# Modify the 7-Zip detection in bulk-extract.ps1
$sevenZipPaths = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe",
    "${env:ProgramFiles}\7-Zip\7z.exe",
    "C:\Tools\7-Zip\7z.exe"  # Add custom path
)

$sevenZip = $null
foreach ($path in $sevenZipPaths) {
    if (Test-Path $path) {
        $sevenZip = $path
        break
    }
}
```

## Example 8: Progress indication
Add Windows notification support:

```powershell
# At the start of extraction
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.Visible = $true
$notification.ShowBalloonTip(3000, "W11Shell", "Starting bulk extraction...", "Info")

# At the end
$notification.ShowBalloonTip(3000, "W11Shell", "Extraction completed: $successCount successful, $failureCount failed", "Info")
$notification.Dispose()
```

## Example 9: Size-based extraction decisions
Only extract archives larger than a certain size:

```javascript
// In shell.nss, add size check
where=sel.count>0 and (sel.files.any((file.ext=='.zip' or file.ext=='.rar' or file.ext=='.7z') and file.size>1048576))
```

## Example 10: Integration with other tools
Call external tools after extraction:

```powershell
# Add after successful extraction
if ($extractionSuccess -and $integrityOk) {
    # Open extracted folder in Windows Explorer
    Start-Process "explorer.exe" -ArgumentList "/select,`"$destinationPath`""
    
    # Or scan with antivirus
    # Start-Process "C:\Program Files\Windows Defender\MpCmdRun.exe" -ArgumentList "-Scan -ScanType 3 -File `"$destinationPath`""
}
```