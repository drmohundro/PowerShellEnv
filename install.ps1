$profileDir = [System.IO.Path]::GetDirectoryName($profile)
$repoRoot = Resolve-Path $PSScriptRoot
$runningOnWindows = $IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop' -or $env:OS -eq 'Windows_NT'

function New-ProfileLink {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path,
        [string]$Target,
        [string]$ItemType
    )

    if (Test-Path $Path) {
        Write-Verbose "Profile path already exists: $Path"
        return
    }

    if ($PSCmdlet.ShouldProcess($Path, "Create profile link to $Target")) {
        New-Item -Path $Path -ItemType $ItemType -Value $Target | Out-Null
    }
}

if ($repoRoot.Path -ne $profileDir) {
    if ($runningOnWindows) {
        # Set up junctions to both Windows PowerShell and PowerShell profile directories.
        $documents = [Environment]::GetFolderPath('MyDocuments')
        New-ProfileLink -Path (Join-Path $documents 'WindowsPowerShell') -Target $repoRoot.Path -ItemType Junction
        New-ProfileLink -Path (Join-Path $documents 'PowerShell') -Target $repoRoot.Path -ItemType Junction
    }
    else {
        $configDir = Join-Path $HOME '.config'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        New-ProfileLink -Path (Join-Path $configDir 'powershell') -Target $repoRoot.Path -ItemType SymbolicLink
    }
}

if ($runningOnWindows) {
    Install-Module VsSetup -Scope CurrentUser -Force
}

Install-Module posh-git -Scope CurrentUser -Force
Install-Module PSReadline -Scope CurrentUser -Force
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
Install-Module PANSIES -AllowClobber -Scope CurrentUser -Force
Install-Module PowerLine -Scope CurrentUser -Force
Install-Module Terminal-Icons -Scope CurrentUser -Force
