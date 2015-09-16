function Write-ScmStatus {
    if ((Get-Location | Select -expand Provider | Select -expand Name) -eq 'FileSystem') {
        if (Has-AnyOfParentPath @('.svn', '.git', '.hg')) {
            $vc = & "$profileDir/scripts/vcprompt.bat" --format-hg '[%s:%b (%r:%h)]'  --format-git '[%s:%b (%r)]'
            write-host $vc -f Gray
        }
        else {
            write-host ' '
        }
    }
    else {
        write-host ' '
    }
}

Add-CallToPrompt { Write-ScmStatus }

function Get-AliasShortcut([string]$commandName) {
    ls Alias: | ?{ $_.Definition -match $commandName }
}

function Start-VisualStudio([string]$path) {
    & devenv /edit $path
}

function bcomp($left, $right) {
    $left = Resolve-Path $left
    $right = Resolve-Path $right
    & 'C:/Program Files (x86)/Beyond Compare 4/BComp.exe' $left, $right
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

function Has-AnyOfParentPath([string[]]$paths) {
    $hasPath = $false
    foreach ($path in $paths) {
        $hasPath = has-parentpath $path
        if ($hasPath) { return $true }
    }
}

function has-parentpath([string]$path) {
    if (test-path $path) {
        return $true;
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
        where {
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

function Start-IisExpressHere {
    Start-IisExpress $pwd.Path
}

$jobName = 'IisExpressJob'
function Start-IisExpress($pathToSource) {
    Start-Job -Name $jobName -Arg $pathToSource -ScriptBlock {
        param ($pathToSource)
        & 'C:\Program Files (x86)\IIS Express\iisexpress.exe' /port:1234 /path:$pathToSource
    }
}

function Stop-IisExpress {
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
