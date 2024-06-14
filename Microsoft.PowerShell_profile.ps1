<#
	PowerShell Profile freaxnx01
#>

# Import modules
# $profileDirectoryPath = Split-Path $profile
# $myModulesDirectoryPath = Join-Path $profileDirectoryPath 'mymodules'
# Get-ChildItem $myModulesDirectoryPath -Filter *.psm1 |
# ForEach-Object {
# 	Import-Module $_.FullName
# }

$customMarker = "<custom>"

# Docker alias
Set-Alias -Name dps -Value Get-ListOfContainer -Description $customMarker
Set-Alias -Name dcps -Value Get-ComposePs -Description $customMarker
Set-Alias -Name up -Value Invoke-ComposeUp -Description $customMarker
Set-Alias -Name down -Value Invoke-ComposeDown -Description $customMarker
Set-Alias -Name remove -Value Invoke-ComposeRemove -Description $customMarker
Set-Alias -Name stop -Value Invoke-ComposeStop -Description $customMarker
Set-Alias -Name dip -Value Get-ContainerIPAddress -Description $customMarker
Set-Alias -Name dstop -Value Invoke-ContainerStop -Description $customMarker
Set-Alias -Name drm -Value Invoke-ContainerRemove -Description $customMarker
Set-Alias -Name dlog -Value Invoke-ContainerLog -Description $customMarker
Set-Alias -Name dconn -Value Invoke-ContainerConnect -Description $customMarker
Set-Alias -Name dfimage -Value Invoke-DockerfileImage -Description $customMarker
Set-Alias -Name dstats -Value Get-DockerStats -Description $customMarker

function Get-ListOfContainer
{
	docker ps -a
}

function Invoke-ComposeUp
{
	docker-compose up -d --remove-orphans
}
function Invoke-ComposeDown
{
	docker-compose down
}

function Invoke-ComposeRemove
{
	docker-compose rm --stop --force
}

function Invoke-ComposeStop
{
	docker-compose stop
}

function Get-ComposePs
{
	docker-compose ps
}

function Get-ContainerIPAddress {
	param (
		[string] $id
	)
	& docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id
}

function Invoke-ContainerStop
{
	param (
		[string] $id
	)
	& docker container stop $id
}

function Invoke-ContainerRemove
{
	param (
		[string] $id
	)
	& docker container rm $id
}
function Invoke-ContainerLog
{
	param (
		[string] $id
	)
	& docker logs --follow $id
}

# Argument: ImageID (docker images)
function Invoke-DockerfileImage
{
	param (
		[string] $id
	)
	& docker run -v /var/run/docker.sock:/var/run/docker.sock --rm laniksj/dfimage $id
}

function Invoke-ContainerConnect
{
	param (
		[string] $id
	)
	& docker exec -it $id /bin/bash
}

function Get-DockerStats
{
	docker stats
}

## grep
Set-Alias grep Select-String

# OS
function IsWindows
{
  return $env:OS -eq "Windows_NT"
}

function IsLinux
{
  if (IsWindows) { return $false }
  return $true
}

# ..
function fcdparent
{
  Set-Location ..
}
Set-Alias -Name .. -Value fcdparent -Description $customMarker

# edit

function Get-ProgramFilesExecutable($1)
{
	$fullPath = Join-Path -Path ${env:ProgramFiles} -ChildPath $1
	if (Test-Path $fullPath)
	{
		return "$fullPath";
	}
	
	$fullPath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath $1
	if (Test-Path $fullPath)
	{
		return "$fullPath";
	}
	
	return $null;
}

$cmd = Get-ProgramFilesExecutable('Notepad++\notepad++.exe')
Set-Alias -Name edit -Value $cmd -Description $customMarker

# ll
Set-Alias -Name ll -Value Get-ChildItem -Description $customMarker

# dirw
function dirwide
{
  Get-ChildItem | Format-Wide
}
Set-Alias -Name dirw -Value dirwide -Description $customMarker
 
# mkdir & cd
function fmkdirandcd($1)
{
  mkdir $1 | Out-Null
  cd $1
}
Set-Alias -Name mkcdir -Value fmkdirandcd -Description $customMarker

# list custom aliases

function flistcustomaliases
{
  flistcustomaliasesForMarker $customMarker
}

function flistcustomaliasesForMarker($customMarkerArg)
{
  alias | Where-Object {$_.Description -Match $customMarkerArg}
}
Set-Alias -Name aliascust -Value flistcustomaliases -Description $customMarker
Set-Alias -Name List-Custom-Aliases -Value aliascust -Description $customMarker

# gitignore
Function GitIgnore {
  param(
    [Parameter(Mandatory=$true)]
    [string[]]$list
  )
  $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
  Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
}

function GitIgnoreCSharp
{
  GitIgnore csharp,visualstudio,visualstudiocode,rider
}
Set-Alias -Name gics -Value GitIgnoreCSharp -Description $customMarker

# Überschreibt current directory, wenn z.B. aus Visual Studio Terminal gestartet wird
# working dir

# $workingDirC = "C:\Transfer"
# $workingDirD = "D:\Transfer"

# if (IsWindows)
# {
#   if (Test-Path $workingDirC) {
#     cd $workingDirC
#   }
#   elseif (Test-Path $workingDirD) {
#     cd $workingDirD
#   }
# }

function StoreSecret($outFilePath)
{
	$passwordToStore = Read-Host -AsSecureString
	$passwordToStore | ConvertFrom-SecureString | Out-File $outFilePath
}
Set-Alias -Name Store-Secret -Value StoreSecret -Description $customMarker

function GenerateFileWithRandomData($size)
{
	# https://www.meziantou.net/generate-large-files-using-powershell.htm

	# Alternative:
	# fsutil file createNew test.txt 10MB

	$fileName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()) + ".pdf"
	#$fileName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()) + " - $size bytes"
	$path = Join-Path $pwd $fileName
	#Write-Host $path

	$content = New-Object byte[] $size
	(New-Object System.Random).NextBytes($content)
	
	# Set-Content is very slow, use .NET method directly
	[System.IO.File]::WriteAllBytes($path, $content)
}
Set-Alias -Name Generate-File -Value GenerateFileWithRandomData -Description $customMarker

function GenerateFileNumberOf($size, $numberOf)
{
	for ($i = 1; $i -le $numberOf; $i++)
	{
		GenerateFileWithRandomData $size
	}
}
Set-Alias -Name Generate-File-Number-Of -Value GenerateFileNumberOf -Description $customMarker

function AddDefenderExclusionFolder($folderPath)
{
	Add-MpPreference -ExclusionPath $folderPath
}
Set-Alias -Name Add-Defender-Exclusion-Folder -Value AddDefenderExclusionFolder -Description $customMarker

function WhichWhere($arg)
{
	# https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/where
	where.exe $arg
}
Set-Alias -Name which -Value WhichWhere -Description $customMarker

# Services

$scriptBlock = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  (Get-WmiObject -ComputerName . -Class Win32_Service).State | Where-Object {
        $_ -like 'Running'
    } | ForEach-Object {
          "$_"
  }
}

Register-ArgumentCompleter -CommandName Stop-Service -ParameterName Name -ScriptBlock $scriptBlock

function StartServiceAndWait($serviceName)
{
	Start-Service $serviceName
	StartOrStopServiceAndWait $serviceName "Running"
}
Set-Alias -Name Start-Service-And-Wait -Value StartServiceAndWait -Description $customMarker

function StopServiceAndWait($serviceName)
{
	Stop-Service $serviceName
	StartOrStopServiceAndWait $serviceName "Stopped"
}
Set-Alias -Name Stop-Service-And-Wait -Value StopServiceAndWait -Description $customMarker

function StartOrStopServiceAndWait($serviceName, $targetStatus)
{
	$maxRepeat = 20
	#$searchStatus = "Running" # change to Stopped if you want to wait for services to start
	
	if ($targetStatus -eq "Running") {
		$searchStatus = "Stopped"
	}

	if ($targetStatus -eq "Stopped") {
		$searchStatus = "Running"
	}

	Write-Host $searchStatus

	do
	{
		$count = (Get-Service $serviceName | ? {$_.status -eq $searchStatus}).count
		$maxRepeat--
		Start-Sleep -Milliseconds 600
	} until ($count -eq 0 -or $maxRepeat -eq 0)
}


# oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/freax.json" | Invoke-Expression