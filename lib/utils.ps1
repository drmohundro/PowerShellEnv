function Has-GitStagedChanges {
    git.exe diff-index --quiet --cached HEAD
    $LASTEXITCODE -eq 1
}

function Has-GitWorkingTreeChanges {
    git.exe diff-files --quiet
    $LASTEXITCODE -eq 1
}

function Get-GitBranch {
    git.exe rev-parse --abbrev-ref HEAD
}

function Write-ScmStatus {
    if ((Get-Location | Select-Object -expand Provider | Select-Object -expand Name) -eq 'FileSystem') {
        if (Has-ParentPath '.git') {
            $branchName = Get-GitBranch
            $changesIndicator = ''

            if (Has-GitStagedChanges) {
                $changesIndicator = ' +'
            }

            if (Has-GitWorkingTreeChanges) {
                $changesIndicator = ' !'
            }

            Write-Host "[$(Get-GitBranch)$($changesIndicator)]" -f Gray
        }
        else {
            Write-Host ' '
        }
    }
    else {
        Write-Host ' '
    }
}

Add-CallToPrompt { Write-ScmStatus }

function Get-AliasShortcut([string]$commandName) {
    Get-ChildItem Alias: | Where-Object{ $_.Definition -match $commandName }
}

function Start-VisualStudio([string]$path) {
    & devenv /edit $path
}

function bcomp($left, $right) {
    $left = Resolve-Path $left
    $right = Resolve-Path $right
    & 'C:/Program Files/Beyond Compare 4/BComp.exe' $left, $right
}

function Open-MruSolution($sln) {
    $mruItems = "HKCU:\Software\Microsoft\VisualStudio\14.0\MRUItems"
    $guids = Get-ChildItem $mruitems |
        Select-Object -ExpandProperty name |
        Foreach-Object { $_.Substring($_.LastIndexOf('\') + 1) }

    [array]$mostRecentlyUsedSlns = $guids |
        Foreach-Object {
            $guid = $_
            Get-ChildItem "$mruItems\$guid" |
                Select-Object -ExpandProperty Property |
                Foreach-Object {
                    $value = Get-ItemPropertyValue "$mruItems\$guid\Items" -Name $_
                    if ($value.Contains('.sln')) {
                        $value.Substring(0, $value.IndexOf('|'))
                    }
                }
        }

    if ([string]::IsNullOrWhitespace($sln)) {
        Write-Host "Recently Used Solutions:`n"
        for ($i = 0; $i -lt $mostRecentlyUsedSlns.Count; $i++) {
            Write-Host "$($i + 1): $($mostRecentlyUsedSlns[$i])"
        }
        $toOpen = Read-Host "`nChoose # to open"
        if ($toOpen -gt 0 -and $toOpen -le $mostRecentlyUsedSlns.Count) {
            Write-Host "Starting $($mostRecentlyUsedSlns[$toOpen - 1])..."
            & $mostRecentlyUsedSlns[$toOpen - 1]
        }
    }
    else {
        foreach ($mru in $mostRecentlyUsedSlns) {
            if ($mru -like "*$sln*") {
                Write-Host "Starting $mru..."
                & $mru
                break
            }
        }
    }
}
Set-Alias o Open-MruSolution

function Elevate-Process {
    $file, [string]$arguments = $args
    $psi = new-object System.Diagnostics.ProcessStartInfo $file
    $psi.Arguments = $arguments
    $psi.Verb = "runas"
    $psi.WorkingDirectory = Get-Location
    [System.Diagnostics.Process]::Start($psi)
}

function Get-LatestErrors([int] $newest = 5) {
    Get-EventLog -LogName Application -Newest $newest -EntryType Error -After $([DateTime]::Today)
}

function Has-ParentPath([string]$path) {
    if (test-path $path) {
        return $true
    }

    $path = "/$path"

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + $path
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $true
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $false
}

function get-parentpath([string]$path) {
    if (test-path $path) {
        return $path
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.hg'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $pathToTest
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $null
}

function find {
    param (
        [switch] $ExactMatch,
        [switch] $ShowAllMatches
    )

    function shouldFilterDirectory {
        param ($item, $directoriesToExclude)

        if ((Select-String -pattern $directoriesToExclude -input $item.DirectoryName) -ne $null) {
            return $true
        }
        else {
            return $false
        }
    }

    $toInclude = "*$args*"
    $toExclude = 'bin', 'obj', '\.git', '\.hg', '\.svn', '_ReSharper\.'

    if ($ExactMatch) {
        $toInclude = $args
    }

    Get-ChildItem -include $toInclude -recurse -exclude $toExclude |
        Where-Object {
            if ($ShowAllMatches) {
                return $true
            }

            if (shouldFilterDirectory $_ $toExclude) {
                return $false
            }
            else {
                return $true
            }
        }
}

function head {
    param (
        $file,
        [int] $lineCount = 10
    )
    Get-Content $file -total $lineCount
}

function To-Binary {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [int]$num
    )
    [Convert]::ToString($num, 2)
}

function To-Hex {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [int]$num
    )
    [Convert]::ToString($num, 16).PadLeft(2, '0')
}

$defaultJobName = 'IisExpressJob'
function Start-IisExpressHere {
    param (
        [int]
        $port = 1234,

        [string]
        $jobName = $defaultJobName,

        [switch]
        $useVsConfig = $false,

        [switch]
        $asJob = $false
    )
    Start-IisExpress -pathToSource $pwd.Path @PsBoundParameters
}

function Start-IisExpress {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $pathToSource,

        [int]
        $port = 1234,

        [string]
        $jobName = $defaultJobName,

        [switch]
        $useVsConfig = $false,

        [switch]
        $asJob = $false
    )

    $iisExpress = 'C:\Program Files (x86)\IIS Express\iisexpress.exe'
    $procArgs = [System.Collections.ArrayList]@()

    $vsConfig = "$pathToSource\.vs\config\applicationHost.config"
    if ($useVsConfig -and (Test-Path $vsConfig)) {
        # TODO: figure out how to get the hosts from the config file or from the solution/project...
        $procArgs.AddRange(("/config:`"$vsConfig`"", '/site:"Host"', '/apppool:"Clr4IntegratedAppPool"'))
    }
    else {
        $procArgs.AddRange(("/config:`"$vsConfig`"", "/port:$port", "/path:`"$(Resolve-Path $pathToSource)`""))
    }

    if ($asJob) {
        Start-Job -Name $jobName -Arg $iisExpress, $procArgs -ScriptBlock {
            param ($iisExpress, $procArgs)
            & $iisExpress @procArgs
        }
    }
    else {
        & $iisExpress @procArgs
    }
}

function Stop-IisExpress {
    param (
        [string]
        $jobName = $defaultJobName
    )

    Stop-Job -Name $jobName
    Remove-Job -Name $jobName
}

function Is64Bit {
    [IntPtr]::Size -eq 8
}

<#
.SYNOPSIS
    Invokes the specified batch file and retains any environment variable changes it makes.
.DESCRIPTION
    Invoke the specified batch file (and parameters), but also propagate any
    environment variable changes back to the PowerShell environment that
    called it.
.PARAMETER Path
    Path to a .bat or .cmd file.
.PARAMETER Parameters
    Parameters to pass to the batch file.
.EXAMPLE
    C:\PS> Invoke-BatchFile "$env:ProgramFiles\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
    Invokes the vcvarsall.bat file.  All environment variable changes it makes will be
    propagated to the current PowerShell session.
.NOTES
    Author: Lee Holmes
#>
function Invoke-BatchFile {
    param([string]$Path, [string]$Parameters)

    $tempFile = [IO.Path]::GetTempFileName()

    ## Store the output of cmd.exe.  We also ask cmd.exe to output
    ## the environment table after the batch file completes
    cmd.exe /c " `"$Path`" $Parameters && set > `"$tempFile`" "

    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$")
        {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }

    Remove-Item $tempFile
}

function Load-VcVars {
    $vcargs = ''
    if (Is64Bit) {
        $vcargs = 'amd64'
    }
    $vcVarsBatchFile = "${env:VS140COMNTOOLS}VsDevCmd.bat"
    Invoke-BatchFile $vcVarsBatchFile $vcargs
}

function Format-Byte {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [long]$number
    )

    $units = " B", "KB", "MB", "GB", "TB"
    $kilobyte = 1024

    if ($number -eq 0) {
        $number
    }
    else {
        $unit = 0
        $result = $number

        while ($result -gt $kilobyte -and $unit -lt $units.Length) {
            $result = $result / $Kilobyte
            $unit = $unit + 1
        }

        [string]::Format("{0,7:0.###} {1}", $result, $units[$unit])
    }
}

# See http://conemu.github.io/en/ConEmuHk.html#Slowdown for details.
function Bypass-ConEmuHk {
    cmd /c -cur_console:i @args
}
