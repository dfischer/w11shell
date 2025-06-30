# W11Shell - Bulk Archive Extraction with Nilesoft Shell

This repository provides a Windows 11 shell extension using [Nilesoft Shell](https://github.com/moudey/Shell) to automate bulk extraction of archive files with intelligent cleanup capabilities.

## Features

- **Bulk Archive Extraction**: Extract multiple archive files simultaneously
- **Smart Folder Creation**: Each archive extracts to a folder named after the archive file
- **Integrity Verification**: Checks extraction success before cleaning up
- **Automatic Cleanup**: Optionally deletes original archives after successful extraction  
- **Multiple Format Support**: ZIP, 7Z, RAR, TAR, GZ, BZ2
- **Native Integration**: Uses Windows native extraction capabilities
- **Context Menu Integration**: Right-click context menu for easy access

## Supported Archive Formats

- **.zip** - ZIP archives (native .NET support)
- **.7z** - 7-Zip archives (requires 7-Zip installation for best compatibility)
- **.rar** - RAR archives
- **.tar** - TAR archives  
- **.gz** - GZIP archives
- **.bz2** - BZIP2 archives

## Prerequisites

### 1. Nilesoft Shell Installation

1. Download Nilesoft Shell from the [official repository](https://github.com/moudey/Shell/releases)
2. Extract the downloaded archive to a permanent location (e.g., `C:\Program Files\Nilesoft Shell`)
3. Run `shell.exe` as Administrator to install the shell extension
4. Restart Windows Explorer or reboot to activate the extension

### 2. Optional: 7-Zip Installation

For better 7Z archive support, install [7-Zip](https://www.7-zip.org/):
1. Download and install 7-Zip
2. Ensure `7z.exe` is in your system PATH or install to default location

## Installation

### Method 1: Direct Integration

1. Clone or download this repository
2. Copy `shell.nss` to your Nilesoft Shell configuration directory
3. Copy the entire `scripts` folder to the same directory as `shell.nss`
4. Restart Windows Explorer: `Ctrl+Shift+Esc` → File → Run → `explorer.exe`

### Method 2: Custom Configuration

1. Locate your Nilesoft Shell installation directory
2. Open the main configuration file (usually `shell.nss`)
3. Add the contents of this repository's `shell.nss` file to your configuration
4. Update the script paths to match your setup
5. Copy the `scripts` folder to your Nilesoft Shell directory

## Configuration Verification

### Test Nilesoft Shell Installation

1. Right-click on any file or folder in Windows Explorer
2. You should see Nilesoft Shell menu items
3. If not visible, check:
   - Windows Explorer restarted after installation
   - Nilesoft Shell service is running
   - User has appropriate permissions

### Test Archive Extraction

1. Create a test ZIP file with some content
2. Right-click on the ZIP file
3. Look for "Extract Here (Auto-folder)" option
4. Test the extraction to ensure it works correctly

## Usage

### Bulk Extraction (with cleanup)

1. Select multiple archive files in Windows Explorer
2. Right-click and choose **"Extract Archives (Bulk)"**
3. Archives will be extracted to individual folders
4. Original archives will be deleted after successful extraction

### Bulk Extraction (keep originals)

1. Select multiple archive files in Windows Explorer  
2. Right-click and choose **"Extract Archives (Keep Originals)"**
3. Archives will be extracted to individual folders
4. Original archives will remain untouched

### Single File Extraction

1. Right-click on any supported archive file
2. Choose **"Extract Here (Auto-folder)"**
3. Archive extracts to a folder named after the file

## How It Works

### Extraction Process

1. **File Analysis**: Script analyzes selected archive files
2. **Folder Creation**: Creates destination folders named after each archive
3. **Extraction**: Uses appropriate method based on file type:
   - ZIP files: .NET ZipFile class
   - 7Z files: 7-Zip executable (if available) or PowerShell fallback
   - Other formats: PowerShell Expand-Archive or Windows Shell COM
4. **Integrity Check**: Verifies extracted files are readable
5. **Cleanup**: Removes original archives (if requested and extraction successful)

### Error Handling

- Failed extractions don't trigger archive deletion
- Duplicate folder names get numeric suffixes
- Detailed error reporting for troubleshooting
- Graceful fallbacks between extraction methods

## Troubleshooting

### Context Menu Not Appearing

- Ensure Nilesoft Shell is properly installed and running
- Check that Windows Explorer has been restarted
- Verify file extensions match supported formats
- Run Nilesoft Shell as Administrator during installation

### Extraction Failures

- **7Z files**: Install 7-Zip for better compatibility
- **Permission errors**: Run as Administrator or check file permissions
- **Path length**: Ensure destination paths aren't too long for Windows
- **Corrupted archives**: Check archive integrity with native tools

### PowerShell Execution Issues

- **Execution Policy**: Script automatically uses `-ExecutionPolicy Bypass`
- **Antivirus**: Whitelist the script if blocked by security software
- **Permissions**: Ensure user has write access to extraction location

## Advanced Configuration

### Custom File Extensions

Edit `shell.nss` to add support for additional archive formats:

```javascript
// Add to the extension check
file.ext=='.tar.gz' or file.ext=='.tgz'
```

### Script Parameters

The PowerShell script supports additional parameters:

```powershell
# Keep original archives
-KeepOriginals

# Verbose output
-Verbose

# Custom destination (modify script)
-DestinationRoot "C:\Extracted"
```

### Performance Tuning

For large numbers of archives:
- Extract to SSD storage for better performance
- Consider processing in smaller batches
- Monitor disk space during bulk operations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly on Windows systems
4. Submit a pull request with detailed description

## License

This project is provided as-is for educational and productivity purposes. Please ensure compliance with your organization's policies when using shell extensions.

## Related Projects

- [Nilesoft Shell](https://github.com/moudey/Shell) - The underlying shell extension framework
- [7-Zip](https://www.7-zip.org/) - Archive utility for enhanced format support
