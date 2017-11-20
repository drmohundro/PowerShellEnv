$ProfileDir = $PSScriptRoot

Push-Location $ProfileDir
. ./PowerShell.ps1
. ./Themes/blackboard.ps1
. ./lib/ise.ps1
Pop-Location
