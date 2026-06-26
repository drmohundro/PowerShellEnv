if ([string]::IsNullOrWhiteSpace($ProfileDir)) {
    $ProfileDir = $PSScriptRoot
}

Push-Location $ProfileDir

if (Get-Module posh-git -ListAvailable) {
    Import-Module posh-git
}

if (Get-Module Terminal-Icons -ListAvailable) {
    Import-Module Terminal-Icons
}

function Write-VcsPrompt {
    if (-not (Get-Command Get-GitStatus -ErrorAction SilentlyContinue)) {
        return
    }

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

if ((Get-Command Set-PowerLinePrompt -ErrorAction SilentlyContinue) -and
    (Get-Command New-PromptText -ErrorAction SilentlyContinue) -and
    (Get-Command Get-ShortenedPath -ErrorAction SilentlyContinue)) {
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
}

. ./lib/utils.ps1
. ./lib/aliases.ps1

$runningOnWindows = $IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop' -or $env:OS -eq 'Windows_NT'
$runningOnMacOS = $IsMacOS -or ($PSVersionTable.Platform -eq 'Unix' -and (uname) -eq 'Darwin')

if ($runningOnWindows) {
    . ./lib/windows.ps1
}
elseif ($runningOnMacOS) {
    . ./lib/mac.ps1
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell --cmd j) -join "`n"
    })
}

# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

if (Test-Path ./TypeData/System.Type.ps1xml) {
    Update-TypeData ./TypeData/System.Type.ps1xml
}

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
