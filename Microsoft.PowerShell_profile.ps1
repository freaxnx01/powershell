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
if ($cmd) { Set-Alias -Name edit -Value $cmd -Description $customMarker }

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

	#Write-Host $searchStatus

	do
	{
		$count = (Get-Service $serviceName | ? {$_.status -eq $searchStatus}).count
		$maxRepeat--
		Start-Sleep -Milliseconds 600
	} until ($count -eq 0 -or $maxRepeat -eq 0)
}


# direnv - per-directory env vars from .envrc
# Run .envrc through Git for Windows' bash, and register our own LocationChanged
# handler (instead of `direnv hook pwsh`) so we can repair direnv's Windows export.
if (Get-Command direnv -ErrorAction SilentlyContinue) {
	$gitBash = 'C:\Program Files\Git\usr\bin\bash.exe'
	if (Test-Path $gitBash) { $env:DIRENV_BASH = $gitBash }

	# `direnv export pwsh` emits both `${env:NAME}='...'` and `Remove-Item env:/Name`
	# for vars whose case it normalised (Path->PATH, ComSpec->COMSPEC, ...). On
	# case-insensitive Windows those hit the SAME variable, and because Go's map
	# order is random the Remove sometimes runs after the Set and nulls it -> PATH
	# (hence cmd/git/oh-my-posh's git segment) disappears. Strip every Remove that
	# has a matching Set (case-insensitively); leave genuine unsets intact. Also
	# convert a POSIX PATH back to Windows form if MSYS2 ever hands one back.
	$global:__DirenvApply = {
		$export = (& { (direnv export pwsh | Out-String) })
		if ($export) {
			$setNames = @([regex]::Matches($export, '\$\{env:([^}]+)\}=') |
				ForEach-Object { $_.Groups[1].Value.ToLower() })
			$export = [regex]::Replace($export, "Remove-Item -LiteralPath 'env:/([^']+)';", {
				param($m)
				if ($setNames -contains $m.Groups[1].Value.ToLower()) { '' } else { $m.Value }
			})
			Invoke-Expression $export
			if ($env:PATH -match '^/') {
				$env:PATH = (& 'C:\Program Files\Git\usr\bin\cygpath.exe' -w -p $env:PATH).Trim()
			}
		}
	}

	$direnvHook = [System.EventHandler[System.Management.Automation.LocationChangedEventArgs]] {
		param([object] $src, [System.Management.Automation.LocationChangedEventArgs] $e)
		end { & $global:__DirenvApply }
	}
	$existing = $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction
	if ($existing) {
		$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = [Delegate]::Combine($existing, $direnvHook)
	} else {
		$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = $direnvHook
	}

	# LocationChangedAction fires only on cd, not at launch, so run once now in case
	# the terminal was opened directly inside a direnv directory.
	& $global:__DirenvApply
}

# oh-my-posh

$ohMyPoshConfigFile = "$env:POSH_THEMES_PATH/freax.json"

if (-Not (Test-Path $ohMyPoshConfigFile))
{
	Invoke-WebRequest -Uri https://raw.githubusercontent.com/freaxnx01/config/main/oh-my-posh/freax.json -OutFile $ohMyPoshConfigFile
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
	oh-my-posh init pwsh --config "$ohMyPoshConfigFile" | Invoke-Expression
}