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
Set-Alias less "less.bat"
Set-Alias grep Select-String
Set-Alias sudo Elevate-Process
Set-Alias color Out-ColorMatchInfo
Set-Alias hg hg-wrapper
Set-Alias tgit tgit-wrapper
Set-Alias e "gvim.exe"
Set-Alias subl "C:\Program Files\Sublime Text 2\sublime_text.exe"
