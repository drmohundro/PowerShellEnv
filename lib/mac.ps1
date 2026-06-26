if (Test-Path /usr/local/bin) {
    $env:PATH = "/usr/local/bin:" + $env:PATH
}

function Bypass-Alias($command) {
    Get-Command $command -Type Application -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path
}

function Run-Ls {
    $eza = Bypass-Alias eza
    if ($eza) {
        & $eza @args
    }
    else {
        Get-ChildItem @args
    }
}
Set-Alias ls Run-Ls
