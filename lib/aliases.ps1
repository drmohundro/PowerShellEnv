Set-Alias vs Start-VisualStudio
Set-Alias gas Get-AliasShortcut

if (Is64Bit) {
    Set-Alias iis "$($env:windir)\system32\inetsrv\InetMgr.exe"
}
else {
    Set-Alias iis C:\windows\sysnative\inetsrv\InetMgr.exe
}

Set-Alias zip 7z
Set-Alias which Get-Command
Set-Alias grep Select-String
Set-Alias sudo Elevate-Process
Set-Alias color Out-ColorMatchInfo
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

# see https://github.com/monochromegane/the_platinum_searcher
function Run-PlatinumSearcher {
    # default to 'smart-case' searches with '-S'
    pt.exe -S --color @args
}
Set-Alias pt Run-PlatinumSearcher

# Some git commands are slow when running in ConEmu and ConEmuHk is injected,
# particularly if diff-so-fancy is being used.
# See http://conemu.github.io/en/ConEmuHk.html#Slowdown for details.
function Run-Git {
    $isRunningConEmu = (Get-ChildItem env:/conemu*).Count -gt 0

    $slowGitParams = ('diff', 'dc')
    $isSlowCommand = $false
    foreach ($command in $slowGitParams) {
        if ($args -contains $command) {
            $isSlowCommand = $true
            break
        }
    }

    if ($isRunningConEmu -and $isSlowCommand) {
        cmd /c -cur_console:i git.exe @args
    }
    else {
        git.exe @args
    }
}
Set-Alias git Run-Git
