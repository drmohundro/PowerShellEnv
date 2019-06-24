$promptCalls = New-Object System.Collections.ArrayList

function ansiWrap($code, $txt) {
    $e = [char]27 + "["
    "${e}${code}m$($txt)${e}0m"
}

function prompt {
    # 30 black, 31 red, 32 green, 33 orange, 34 purple, 35 magenta, 36 cyan
    $prompt = "`n"

    $shortedPath = (Shorten-Path (Get-Location).Path)

    $prompt += ansiWrap 32 $([Environment]::MachineName)
    $prompt += ansiWrap 36 " {"
    $prompt += ansiWrap 96 $shortedPath
    $prompt += ansiWrap 36 "} "

    $promptCalls | ForEach-Object { $prompt += $_.Invoke() }

    $prompt += "`n"

    $prompt += ansiWrap 96 "$([char]0x00BB) "

    $prompt

    $host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
    $host.UI.RawUI.WindowTitle = $shortedPath
}

function Add-CallToPrompt([scriptblock] $block) {
    [void]$promptCalls.Add($block)
}

function Shorten-Path([string] $path = $pwd) {
    $shortenPathLength = 3

    $loc = $path.Replace($HOME, '~')

    # remove prefix for UNC paths
    $loc = $loc -replace '^[^:]+::', ''

    # make path shorter like tabs in Vim,
    # handle paths starting with \\ and . correctly
    return ($loc -replace "\\(\.?)([^\\]{$shortenPathLength})[^\\]*(?=\\)", '\$1$2')
}

Add-CallToPrompt -block {
    $jobs = Get-Job

    $output = ''

    if ($jobs.Count -gt 0) {
        $output += ansiWrap 35 '['
        $output += ansiWrap 35 Join-String $($jobs | ForEach-Object { "$($_.Id):$($_.Name)" }) -Separator ', '
        $output += ansiWrap 35 ']'
    }

    $output
}
