<#
    -source "/download/Changelog/Rev08_changelog.html" -operation Download -target "C:\Users\andreas.imboden.e3k\Downloads\"
    
    -source "C:\Users\andreas.imboden.e3k\Downloads\Rev08_changelog.html" -operation Upload -target "/download/Changelog/Rev08_changelog-xyz.html"
    -source "C:\Users\andreas.imboden.e3k\Downloads\---Rev08_changelog.html" -operation Upload -target "/download/Changelog/"

    -source "C:\Transfer\x\asien4000\" -operation Mirror -target "/download/Test_IAN/test"

    # Sync Rev09
    "C:\Users\andreas.imboden.e3k\.dotnet\tools\pwsh.exe" C:\Develop\Scripts\e3k-ftp\e3k-ftp.ps1 -source C:\Transfer\x\asien4000\ -operation Sync -target /download/Master/MasterFT3_Rev09/asien4000

    # Sync Rev08
    "C:\Users\andreas.imboden.e3k\.dotnet\tools\pwsh.exe" C:\Develop\Scripts\e3k-ftp\e3k-ftp.ps1 -source C:\Transfer\x\Rev08\asien4000\ -operation Sync -target /download/Master/MasterFT3_Rev08/asien4000

    # Sync Exclude
    "C:\Users\andreas.imboden.e3k\.dotnet\tools\pwsh.exe" C:\Develop\Scripts\e3k-ftp\e3k-ftp.ps1 -source c:\Develop\V50Master_Rev09\ -operation Sync -target /download/Diverses/Test/asien4000

    # Remove files older than 30 days (modified date)
    -operation Remove -target "/download/Test_IAN/test/*.txt<30D"
    -operation Remove -target "/download/MasterBeta/Trunk_Beta_Setup_nicht_fuer_Kunden/TagesBinBeta/*.zip<30D"
#>

param (
    [string]$source,
    [string]$operation = "Download",
    [string]$target
)

Write-Host "Script root: $($PSScriptRoot)"

Write-Host "Source: $($source)"
Write-Host "Operation: $($operation)"
Write-Host "Target: $($target)"

try
{
    # Load WinSCP .NET assembly
    Add-Type -Path (Join-Path $PSScriptRoot "WinSCPnet.dll")
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Ftp
        HostName = "xyz"
        UserName = "???"
        Password = "???"
        FtpSecure = [WinSCP.FtpSecure]::Explicit
    }
 
    $session = New-Object WinSCP.Session
    $session.DisableVersionCheck = $true
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Download files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

        if ($operation -eq "download") {
            $transferResult = 
                $session.GetFiles($source, $target, $False, $transferOptions)
        }

        if ($operation -eq "upload") {
            $transferResult = 
                $session.PutFiles($source, $target, $False, $transferOptions)
        }

        if ($operation -eq "remove") {
            $transferResult = 
                $session.RemoveFiles($target)
        }

        if ($operation -eq "mirror") {
            if (!($session.FileExists($target)))
            {
                Write-Host "Create directory: $($target)"
                $session.CreateDirectory($target)
            }

            $removeFiles = $true
            $mirror = $true

            $transferResult =
                $session.SynchronizeDirectories([WinSCP.SynchronizationMode]::Remote, $source, $target,
                $removeFiles, $mirror, [WinSCP.SynchronizationCriteria]::Either, $transferOptions)
        }

        if ($operation -eq "sync") {
            if (!($session.FileExists($target)))
            {
                Write-Host "Create directory: $($target)"
                $session.CreateDirectory($target)
            }

            $transferOptions.FileMask = "*; */ | .svn/; bin1/; bin2/"

            $removeFiles = $true
            $mirror = $false

            $transferResult =
                $session.SynchronizeDirectories([WinSCP.SynchronizationMode]::Remote, $source, $target,
                $removeFiles, $mirror, [WinSCP.SynchronizationCriteria]::Either, $transferOptions)
        }
        
        # Throw on any error
        $transferResult.Check()
 
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
            Write-Host "$($operation) of $($transfer.FileName) succeeded"
        }
        foreach ($transfer in $transferResult.Uploads)
        {
            Write-Host "$($operation) of $($transfer.Destination) succeeded"
        }
        foreach ($transfer in $transferResult.Removals)
        {
            Write-Host "$($operation) of $($transfer.FileName) succeeded"
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}