#!/bin/bash

mkdir -p ~/.config/powershell
ln -s /admin/data/powershell/Microsoft.PowerShell_profile.ps1 ~/.config/powershell/Microsoft.PowerShell_profile.ps1
ln -s /admin/data/powershell/mymodules ~/.config/powershell/mymodules

# root
sudo mkdir -p /root/.config/powershell
sudo ln -s /admin/data/powershell/Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
sudo ln -s /admin/data/powershell/mymodules /root/.config/powershell/mymodules
