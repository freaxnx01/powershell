# PowerShell 7
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Documents\PowerShell\"

# Profile System
$fileName = "Microsoft.PowerShell_profile.ps1"
$target = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\$fileName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $fileName
}

# Profile Documents
$fileName = "Microsoft.PowerShell_profile.ps1"
$target = "$env:USERPROFILE\Documents\WindowsPowerShell\$fileName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $fileName
}

# Profile Documents, PowerShell 7
$fileName = "Microsoft.PowerShell_profile.ps1"
$target = "$env:USERPROFILE\Documents\PowerShell\$fileName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $fileName
}

# Profile VSCode
$fileName = "Microsoft.PowerShell_profile.ps1"
$targetFileName = "Microsoft.VSCode_profile.ps1"
$target = "$env:USERPROFILE\Documents\WindowsPowerShell\$targetFileName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $fileName
}

# mymodules
$directoryName = "mymodules"
$target = "$env:USERPROFILE\Documents\WindowsPowerShell\$directoryName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $directoryName
}

# mymodules, PowerShell 7
$directoryName = "mymodules"
$target = "$env:USERPROFILE\Documents\PowerShell\$directoryName"
if ((Test-Path $target) -eq $false) {
	New-Item -ItemType SymbolicLink -Path $target -Value $directoryName
}

Write-Host "Press any key to continue...."
[void][System.Console]::ReadKey($true)