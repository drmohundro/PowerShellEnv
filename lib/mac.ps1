#Set-Alias j

if (Test-Path /usr/local/bin) {
    $env:PATH = "/usr/local/bin:" + $env:PATH
}

if ($null -ne (Get-Command brew -ErrorAction SilentlyContinue)) {
    $env:PATH = "/usr/local/opt/coreutils/libexec/gnubin:" + $env:PATH
    $env:PATH = "/usr/local/opt/findutils/libexec/gnubin:" + $env:PATH
    $env:PATH = "/usr/local/opt/grep/libexec/gnubin:" + $env:PATH
}

function Bypass-Alias($command) {
    Get-Command $command -Type Application | Select-Object -First 1 -ExpandProperty Path
}

function Run-Ls {
    & (Bypass-Alias exa) @args
}
Set-Alias ls Run-Ls

function FasdCd {
    $ret = fasd @args
    if ($null -ne $ret) {
        Set-Location -Path $ret
    }
}
Set-Alias j FasdCd