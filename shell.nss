// Nilesoft Shell Configuration for Bulk Archive Extraction
// Place this file in the Nilesoft Shell configuration directory

menu(mode="multiple" type="*" where=sel.count>0 and (sel.files.any(file.ext=='.zip' or file.ext=='.rar' or file.ext=='.7z' or file.ext=='.tar' or file.ext=='.gz' or file.ext=='.bz2')))
{
	separator

	item(title='Extract Archives (Bulk)' image=icon.archive)
	{
		cmd='powershell.exe'
		args='-ExecutionPolicy Bypass -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.files@"'
		tip='Extract all selected archive files to separate folders and clean up originals'
	}

	item(title='Extract Archives (Keep Originals)' image=icon.archive)
	{
		cmd='powershell.exe'
		args='-ExecutionPolicy Bypass -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.files@" -KeepOriginals'
		tip='Extract all selected archive files to separate folders but keep original archives'
	}

	separator
}

// Alternative single-file context menu for individual archive extraction
menu(type="file" where=file.ext=='.zip' or file.ext=='.rar' or file.ext=='.7z' or file.ext=='.tar' or file.ext=='.gz' or file.ext=='.bz2')
{
	separator

	item(title='Extract Here (Auto-folder)' image=icon.archive)
	{
		cmd='powershell.exe'
		args='-ExecutionPolicy Bypass -File "@app.dir@\scripts\bulk-extract.ps1" "@sel.path@"'
		tip='Extract archive to a folder named after the archive file'
	}

	separator
}