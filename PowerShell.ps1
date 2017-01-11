$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

$global:shortenPathLength = 3

$promptCalls = New-Object System.Collections.ArrayList

function prompt {
    $chost = [ConsoleColor]::Green
    $cdelim = [ConsoleColor]::DarkCyan
    $cloc = [ConsoleColor]::Cyan

    Write-Host ' '

    Write-Host ([Environment]::MachineName) -nonewline -foregroundcolor $chost
    Write-Host ' {' -nonewline -foregroundcolor $cdelim
    Write-Host (Shorten-Path (Get-Location).Path) -nonewline -foregroundcolor $cloc
    Write-Host '} ' -nonewline -foregroundcolor $cdelim

    $promptCalls | ForEach-Object { $_.Invoke() }

    Write-Host $([char]0x00BB) -nonewline -foregroundcolor $cloc
    ' '

    $host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
}

function Shorten-Path([string] $path = $pwd) {
   $loc = $path.Replace($HOME, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace "\\(\.?)([^\\]{$shortenPathLength})[^\\]*(?=\\)",'\$1$2')
}

function Add-CallToPrompt([scriptblock] $block) {
    [void]$promptCalls.Add($block)
}

function Add-ToPath([string] $newPath, [switch] $permanent = $false) {
    $env:Path += ";$(Resolve-Path $newPath)" 

    if ($permanent) {
        [Environment]::SetEnvironmentVariable('Path', $env:Path, [EnvironmentVariableTarget]::Machine)
    }
}

Add-CallToPrompt -block {
    $jobs = Get-Job
    if ($jobs.Count -gt 0) {
        Write-Host -noNewLine '[' -foregroundcolor Magenta
        $status = Join-String $($jobs | ForEach-Object { "$($_.Id):$($_.Name)" }) -Separator ', '
        Write-Host -noNewLine $status -foregroundcolor Magenta
        Write-Host -noNewLine ']' -foregroundcolor Magenta
    }
}

if (Test-Path c:\Python27) {
    Add-ToPath "c:\Python27"
}

Import-Module Pscx -DisableNameChecking -arg "$(Split-Path $profile -parent)\Pscx.UserPreferences.ps1"
Import-Module posh-git
Import-Module ZLocation

# override the PSCX cmdlets with the default cmdlet
Set-Alias Select-Xml Microsoft.PowerShell.Utility\Select-Xml

Push-Location $ProfileDir
    # Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
    If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

    # Bring in prompt and other UI niceties
    . ./EyeCandy.ps1

    Update-TypeData ./TypeData/System.Type.ps1xml
    Update-TypeData ./TypeData/System.Diagnostics.Process.ps1xml

    Update-FormatData -PrependPath ./Formats.ps1xml

    . ./lib/utils.ps1
    . ./lib/aliases.ps1
Pop-Location

if ((Get-Module PSReadLine -ListAvailable) -ne $null) {
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode Emacs
    Set-PSReadlineOption -BellStyle None

    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}

Load-VcVars
