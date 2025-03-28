if (Is64Bit) {
    Set-Alias iis "$($env:windir)\system32\inetsrv\InetMgr.exe"
}
else {
    Set-Alias iis C:\windows\sysnative\inetsrv\InetMgr.exe
}

Set-Alias which Get-Command
Set-Alias grep Select-String

Set-Alias e "gvim.exe"
Set-Alias mvim "gvim.exe"
Set-Alias subl "C:\Program Files\Sublime Text\sublime_text.exe"
Set-Alias open Start-Process

Invoke-Expression (& { (mise activate pwsh | Out-String) })

function bcomp($left, $right) {
    $left = Resolve-Path $left
    $right = Resolve-Path $right
    & 'C:/Program Files/Beyond Compare 5/BComp.exe' $left $right
}

function msbuild {
    & (Join-Path (Get-VSSetupInstance | Select-Object -ExpandProperty InstallationPath -Last 1) 'MSBuild\Current\Bin\MSBuild.exe') @args
}

function sqlpackage {
    & (Join-Path (Get-VSSetupInstance | Select-Object -ExpandProperty InstallationPath -Last 1) 'Common7\IDE\Extensions\Microsoft\SQLDB\DAC\150\sqlpackage.exe') @args
}

function head {
    param (
        $file,
        [int] $lineCount = 10
    )
    Get-Content $file -total $lineCount
}

function Get-LatestErrors([int] $newest = 5) {
    Get-EventLog -LogName Application -Newest $newest -EntryType Error -After $([DateTime]::Today)
}
