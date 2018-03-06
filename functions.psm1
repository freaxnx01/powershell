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
