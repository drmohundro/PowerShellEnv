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

function Is-Mac {
    $OS -eq 'mac'
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
        $history = $history | Where-Object { $_ -match $lookup }
    }

    if ([Console]::WindowHeight -gt $history.Count) {
        $history
    }
    else {
        $history | less
    }
}

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
    while ($null -ne $checkIn) {
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

function Split-String {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]
        $input,

        [string]
        $separator,

        [switch]
        $newLine
    )

    if ($newLine) {
        [Regex]::Split($input, "`n")
    }
    else {
        [Regex]::Split($input, $separator)
    }
}
