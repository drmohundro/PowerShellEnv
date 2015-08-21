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
Set-Alias hg hg-wrapper
Set-Alias tgit tgit-wrapper
Set-Alias e "gvim.exe"
Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"
Set-Alias open Start-Process

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
