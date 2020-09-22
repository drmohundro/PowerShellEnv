Set-Alias gas Get-AliasShortcut
Set-Alias color Out-ColorMatchInfo

function Run-RipGrep {
    # default to 'smart-case' searches with '-S'
    & (Get-Command rg -CommandType Application) -S @args
}
Set-Alias rg Run-RipGrep
