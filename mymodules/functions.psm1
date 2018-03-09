function Get-ProfileDirectoryPath
{
	return Split-Path $profile
}

function New-TemporaryDirectory
{
	$parent = [System.IO.Path]::GetTempPath()
	[string] $name = [System.Guid]::NewGuid()
	New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Get-Guid
{
	return [System.Guid]::NewGuid()
}

function Install-OpenHereAsAdministrator
{
	$menu = 'Open Windows PowerShell Here as Administrator'
	$command = "$PSHOME\powershell.exe -NoExit -Command ""Set-Location '%V'"""

	'directory', 'directory\background', 'drive' | ForEach-Object {
		New-Item -Path "Registry::HKEY_CLASSES_ROOT\$_\shell" -Name runas\command -Force |
		Set-ItemProperty -Name '(default)' -Value $command -PassThru |
		Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $menu -PassThru |
		Set-ItemProperty -Name HasLUAShield -Value ''
	}
}