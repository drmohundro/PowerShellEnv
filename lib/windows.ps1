if (Is64Bit) {
    Set-Alias iis "$($env:windir)\system32\inetsrv\InetMgr.exe"
}
else {
    Set-Alias iis C:\windows\sysnative\inetsrv\InetMgr.exe
}

Set-Alias which Get-Command
Set-Alias grep Select-String
Set-Alias sudo Elevate-Process

Set-Alias e "gvim.exe"
Set-Alias mvim "gvim.exe"
Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"
Set-Alias open Start-Process

# support `j ~/path`
function MySet-ZLocation($path) {
    if (Test-Path $path) {
        Set-ZLocation $(Resolve-Path $path)
    }
    else {
        Set-ZLocation $path
    }
}
Set-Alias j MySet-ZLocation

function bcomp($left, $right) {
    $left = Resolve-Path $left
    $right = Resolve-Path $right
    & 'C:/Program Files/Beyond Compare 4/BComp.exe' $left $right
}

function msbuild {
    & (Join-Path (Get-VSSetupInstance | Select-Object -ExpandProperty InstallationPath) 'MSBuild\Current\Bin\MSBuild.exe') @args
}

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