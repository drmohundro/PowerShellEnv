Push-Location $ProfileDir

. ./lib/prompt.ps1
. ./lib/utils.ps1
. ./lib/aliases.ps1

if (Is-Windows) {
    Import-Module ZLocation

    # override the PSCX cmdlets with the default cmdlet
    Set-Alias Select-Xml Microsoft.PowerShell.Utility\Select-Xml
}

Import-Module posh-git

# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

Update-TypeData ./TypeData/System.Type.ps1xml
Update-TypeData ./TypeData/System.Diagnostics.Process.ps1xml

Update-FormatData -PrependPath ./Formats.ps1xml

Pop-Location

if ((Get-Module PSReadLine -ListAvailable) -ne $null) {
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode Emacs
    Set-PSReadlineOption -BellStyle None

    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}
