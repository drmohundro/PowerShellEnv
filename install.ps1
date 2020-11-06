$profileDir = [System.IO.Path]::GetDirectoryName($profile)

if ($PSScriptRoot -ne $profileDir) {
    if ($IsWindows) {
        # set up a junction to the profile directory
        cmd /c mklink /J "$(Resolve-Path ~\Documents)\WindowsPowerShell" $(Resolve-Path .)
        cmd /c mklink /J "$(Resolve-Path ~\Documents)\PowerShell" $(Resolve-Path .)
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
