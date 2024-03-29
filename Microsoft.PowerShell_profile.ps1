<#
	PowerShell Profile
#>

# Import modules
$profileDirectoryPath = Split-Path $profile
$myModulesDirectoryPath = Join-Path $profileDirectoryPath 'mymodules'
Get-ChildItem $myModulesDirectoryPath -Filter *.psm1 |
ForEach-Object {
	Import-Module $_.FullName
}

$customMarker = "<custom>"
$workingDirC = "C:\Transfer"
$workingDirD = "D:\Transfer"

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
  alias | Where-Object {$_.Description -Match $customMarker}
}
Set-Alias -Name aliascust -Value flistcustomaliases -Description $customMarker

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

# working dir
if (IsWindows)
{
  if (Test-Path $workingDirC) {
    cd $workingDirC
  }
  elseif (Test-Path $workingDirD) {
    cd $workingDirD
  }
}
