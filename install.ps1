$profileDir = [System.IO.Path]::GetDirectoryName($profile)

if ($PSScriptRoot -ne $profileDir) {
    if ($IsWindows) {
        # set up a junction to the profile directory
        New-Item -Path "$(Resolve-Path ~\Documents)\WindowsPowerShell" -ItemType Junction -Value $(Resolve-Path .)
        New-Item -Path "$(Resolve-Path ~\Documents)\PowerShell" -ItemType Junction -Value $(Resolve-Path .)
    } else {
        ln -s "$(Resolve-Path .)" "$(Resolve-Path ~/.config)/powershell"
    }
}

if ($IsWindows) {
    Install-Module ZLocation -Scope CurrentUser -Force
    Install-Module VsSetup -Scope CurrentUser -Force
}

Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadline -Scope CurrentUser -Force
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
Install-Module PANSIES -AllowClobber -Scope CurrentUser -Force
Install-Module PowerLine -Scope CurrentUser -Force
