<#
	PowerShell Profile
#>

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

# ll
Set-Alias -Name ll -Value Get-ChildItem -Description $customMarker

if (IsWindows)
{
  # Notepad++
  function fnp++
  {
    start "${env:ProgramFiles(x86)}\notepad++\notepad++.exe"
  }
  Set-Alias -Name np++ -Value fnp++ -Description $customMarker

  # Notepad
  Set-Alias -Name np -Value notepad -Description $customMarker
}
 
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

# Import modules
$profileDirectoryPath = Split-Path $profile
$myModulesDirectoryPath = Join-Path $profileDirectoryPath 'mymodules'
Get-ChildItem $myModulesDirectoryPath -Filter *.psm1 |
ForEach-Object {
	Import-Module $_.FullName
}

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
