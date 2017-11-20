function Get-OS {
    $os = switch -regex ($PSVersionTable.OS) {
        '^Darwin' { 'mac' }
        Default { 'win' }
    }
    $os
}
$OS = Get-OS

function Is-Windows {
    $OS -eq 'win'
}

function Has-GitStagedChanges {
    git diff-index --quiet --cached HEAD
    $LASTEXITCODE -eq 1
}

function Has-GitWorkingTreeChanges {
    git diff-files --quiet
    $LASTEXITCODE -eq 1
}

function Get-GitBranch {
    git rev-parse --abbrev-ref HEAD
}

# use PSReadLine history (which works across sessions) instead of built-in history
function Get-History {
    param (
        [string] $lookup = $null
    )

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath)) {
            if ($line.EndsWith('`')) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines) {
                    "$lines`n$line"
                }
                else {
                    $line
                }
                continue
            }

            if ($lines) {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    if (-not ([string]::IsNullOrWhiteSpace($lookup))) {
        $history = $history | Where { $_ -match $lookup }
    }

    if ([Console]::WindowHeight -gt $history.Count) {
        $history
    }
    else {
        $history | less
    }
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

            ansiWrap 33 "[$(Get-GitBranch)$($changesIndicator)]"
        }
        else {
            ' '
        }
    }
    else {
        ' '
    }
}

Add-CallToPrompt { Write-ScmStatus }

function Add-ToPath([string] $newPath, [switch] $permanent = $false) {
    $env:Path += ";$(Resolve-Path $newPath)"

    if ($permanent) {
        [Environment]::SetEnvironmentVariable('Path', $env:Path, [EnvironmentVariableTarget]::Machine)
    }
}

function Get-AliasShortcut([string]$commandName) {
    Get-ChildItem Alias: | Where-Object { $_.Definition -match $commandName }
}

function Has-ParentPath([string]$path) {
    if (test-path $path) {
        return $true
    }

    $path = "/$path"

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.FullName + $path
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $true
        }
        else {
            $checkIn = $checkIn.Parent
        }
    }

    return $false
}

function To-Binary {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [int]$num
    )
    [Convert]::ToString($num, 2)
}

function To-Hex {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [int]$num
    )
    [Convert]::ToString($num, 16).PadLeft(2, '0')
}

function Is64Bit {
    [IntPtr]::Size -eq 8
}

function Format-Byte {
    param (
        [Parameter(ValueFromPipeline = $true)]
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

if (Is-Windows) {
    function head {
        param (
            $file,
            [int] $lineCount = 10
        )
        Get-Content $file -total $lineCount
    }

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
            [Parameter(Mandatory = $true)]
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
}
