Push-Location $ProfileDir

Import-Module posh-git
Import-Module Terminal-Icons

function Write-VcsPrompt {
    $git = Get-GitStatus -WarningAction SilentlyContinue

    if ($null -ne $git) {
        $text = "  $($git.Branch)"
        if ($git.HasWorking) {
            $text = $text + " +"
        }
        if ($git.HasUntracked) {
            $text = $text + " !"
        }
        New-PromptText "$text " -BackgroundColor Yellow -ForegroundColor Black
    }
}

$global:prompt = @(
    { "`n" }
    { " $(Get-ShortenedPath -SingleCharacterSegment) " }
    { "`t" } # right align
    { Write-VcsPrompt }
    { " $(Get-Date -f "T") " }
    { "`n" }
    { New-PromptText $([char]0x00BB) -BackgroundColor Black -ForegroundColor Cyan }
)

Set-PowerLinePrompt -Colors "#00DDFF", "#0066FF" -RestoreVirtualTerminal:$false -SetCurrentDirectory -PowerLineFont -Title {
    -join @(if (Test-Elevation) { "Administrator: " }
        Get-ShortenedPath -SingleCharacterSegment)
}

. ./lib/utils.ps1
. ./lib/aliases.ps1

if ($IsWindows) {
    . ./lib/windows.ps1
}
elseif ($IsMacOS) {
    . ./lib/mac.ps1
}

Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell --cmd j) -join "`n"
})

# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

Update-TypeData ./TypeData/System.Type.ps1xml

# Update-FormatData -PrependPath ./Formats.ps1xml

Pop-Location

if ($null -ne (Get-Module PSReadLine -ListAvailable)) {
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode Emacs
    Set-PSReadlineOption -BellStyle None

    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}
