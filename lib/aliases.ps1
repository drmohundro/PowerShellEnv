Set-Alias gas Get-AliasShortcut

if (Is-Windows) {
    Set-Alias vs Start-VisualStudio

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

    function MarkdownPad($path) {
        $path = Resolve-Path $Path
        & "C:\Program Files (x86)\MarkdownPad 2\MarkdownPad2.exe" $path
    }
    Set-Alias mpad MarkdownPad

    function Start-VisualStudio([string]$path) {
        & devenv /edit $path
    }

    function bcomp($left, $right) {
        $left = Resolve-Path $left
        $right = Resolve-Path $right
        & 'C:/Program Files/Beyond Compare 4/BComp.exe' $left, $right
    }

    function msbuild {
        & (Join-Path (Get-VSSetupInstance | Select-Object -ExpandProperty InstallationPath) 'MSBuild\15.0\Bin\MSBuild.exe') @args
    }
}

Set-Alias color Out-ColorMatchInfo

function Run-PlatinumSearcher {
    # default to 'smart-case' searches with '-S'
    & (Get-Command pt -CommandType Application) -S --color @args
}
Set-Alias pt Run-PlatinumSearcher

function Run-RipGrep {
    # default to 'smart-case' searches with '-S'
    & (Get-Command rg -CommandType Application) -S @args
}
Set-Alias rg Run-RipGrep
