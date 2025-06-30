param(
    [Parameter(Mandatory=$true)]
    [string[]]$ArchiveFiles,
    
    [switch]$KeepOriginals
)

# Function to extract archive using Windows native capabilities
function Extract-Archive {
    param(
        [string]$ArchivePath,
        [string]$DestinationPath
    )
    
    try {
        # Create destination directory if it doesn't exist
        if (!(Test-Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        }
        
        # Get file extension to determine extraction method
        $extension = [System.IO.Path]::GetExtension($ArchivePath).ToLower()
        
        Write-Host "Extracting: $ArchivePath -> $DestinationPath" -ForegroundColor Green
        
        switch ($extension) {
            ".zip" {
                # Use .NET's ZipFile class for ZIP files
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $DestinationPath)
            }
            ".7z" {
                # Try to use 7-Zip if available, otherwise use Expand-Archive
                $sevenZip = Get-Command "7z.exe" -ErrorAction SilentlyContinue
                if ($sevenZip) {
                    & 7z.exe x "$ArchivePath" "-o$DestinationPath" -y
                    if ($LASTEXITCODE -ne 0) {
                        throw "7-Zip extraction failed with exit code $LASTEXITCODE"
                    }
                } else {
                    # Fallback to PowerShell's Expand-Archive (may not work with all 7z files)
                    Expand-Archive -Path $ArchivePath -DestinationPath $DestinationPath -Force
                }
            }
            default {
                # Try PowerShell's Expand-Archive for other formats
                try {
                    Expand-Archive -Path $ArchivePath -DestinationPath $DestinationPath -Force
                } catch {
                    # Fallback: try to use Windows Shell to extract
                    $shell = New-Object -ComObject Shell.Application
                    $zip = $shell.NameSpace($ArchivePath)
                    $dest = $shell.NameSpace($DestinationPath)
                    
                    if ($zip -ne $null) {
                        $dest.CopyHere($zip.Items(), 1564)
                    } else {
                        throw "Unable to open archive with Windows Shell"
                    }
                }
            }
        }
        
        return $true
    } catch {
        Write-Error "Failed to extract $ArchivePath`: $($_.Exception.Message)"
        return $false
    }
}

# Function to verify extraction integrity
function Test-ExtractionIntegrity {
    param(
        [string]$DestinationPath
    )
    
    try {
        # Check if destination folder exists and has content
        if (!(Test-Path $DestinationPath)) {
            return $false
        }
        
        $items = Get-ChildItem $DestinationPath -Recurse
        if ($items.Count -eq 0) {
            return $false
        }
        
        # Basic integrity check: ensure we have readable files
        $hasValidFiles = $false
        foreach ($item in $items) {
            if (!$item.PSIsContainer) {
                try {
                    [System.IO.File]::ReadAllBytes($item.FullName) | Out-Null
                    $hasValidFiles = $true
                    break
                } catch {
                    continue
                }
            }
        }
        
        return $hasValidFiles
    } catch {
        return $false
    }
}

# Main extraction logic
$successCount = 0
$failureCount = 0
$processedFiles = @()

Write-Host "Starting bulk archive extraction..." -ForegroundColor Cyan
Write-Host "Keep originals: $KeepOriginals" -ForegroundColor Cyan

foreach ($archiveFile in $ArchiveFiles) {
    if (!(Test-Path $archiveFile)) {
        Write-Warning "File not found: $archiveFile"
        $failureCount++
        continue
    }
    
    # Get the archive file info
    $fileInfo = Get-Item $archiveFile
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
    $parentDir = $fileInfo.DirectoryName
    
    # Create destination folder name (handle potential conflicts)
    $destinationBase = Join-Path $parentDir $baseName
    $destinationPath = $destinationBase
    $counter = 1
    
    while (Test-Path $destinationPath) {
        $destinationPath = "${destinationBase}_${counter}"
        $counter++
    }
    
    Write-Host "`nProcessing: $($fileInfo.Name)" -ForegroundColor Yellow
    
    # Extract the archive
    $extractionSuccess = Extract-Archive -ArchivePath $archiveFile -DestinationPath $destinationPath
    
    if ($extractionSuccess) {
        # Verify extraction integrity
        Write-Host "Verifying extraction integrity..." -ForegroundColor Cyan
        $integrityOk = Test-ExtractionIntegrity -DestinationPath $destinationPath
        
        if ($integrityOk) {
            Write-Host "Extraction successful and verified!" -ForegroundColor Green
            $successCount++
            
            # Delete original archive if requested and extraction was successful
            if (!$KeepOriginals) {
                try {
                    Remove-Item $archiveFile -Force
                    Write-Host "Original archive deleted: $($fileInfo.Name)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to delete original archive: $($_.Exception.Message)"
                }
            }
            
            $processedFiles += @{
                Archive = $archiveFile
                Destination = $destinationPath
                Status = "Success"
            }
        } else {
            Write-Error "Extraction integrity check failed for $($fileInfo.Name)"
            $failureCount++
            
            # Clean up failed extraction folder
            if (Test-Path $destinationPath) {
                Remove-Item $destinationPath -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            $processedFiles += @{
                Archive = $archiveFile
                Destination = $destinationPath
                Status = "Failed (Integrity)"
            }
        }
    } else {
        $failureCount++
        $processedFiles += @{
            Archive = $archiveFile
            Destination = $destinationPath
            Status = "Failed (Extraction)"
        }
    }
}

# Summary report
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "BULK EXTRACTION SUMMARY" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan
Write-Host "Total files processed: $($successCount + $failureCount)" -ForegroundColor White
Write-Host "Successful extractions: $successCount" -ForegroundColor Green
Write-Host "Failed extractions: $failureCount" -ForegroundColor Red
Write-Host "Keep originals: $KeepOriginals" -ForegroundColor White

if ($processedFiles.Count -gt 0) {
    Write-Host "`nDetailed Results:" -ForegroundColor Cyan
    foreach ($file in $processedFiles) {
        $color = if ($file.Status -eq "Success") { "Green" } else { "Red" }
        Write-Host "  $($file.Status): $([System.IO.Path]::GetFileName($file.Archive))" -ForegroundColor $color
    }
}

Write-Host "`nBulk extraction completed!" -ForegroundColor Cyan

# Exit with appropriate code
if ($failureCount -eq 0) {
    exit 0
} else {
    exit 1
}