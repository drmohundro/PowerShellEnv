$profileDir = "$(Resolve-Path ~\Documents)\WindowsPowerShell"

if ($PSScriptRoot -ne $profileDir) {
    # set up a junction to the profile directory
    cmd /c mklink /J "$(Resolve-Path ~\Documents)\WindowsPowerShell" $(Resolve-Path .)
}

Install-Module Find-String
Install-Module ZLocation
Install-Module posh-git
Install-Module Pscx -AllowClobber
Install-Module PSReadline
Install-Module PSScriptAnalyzer
