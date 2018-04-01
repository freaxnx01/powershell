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
