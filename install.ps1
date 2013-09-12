# installs listed modules

function ensurePsGetExists {
    if ((Get-Module PsGet) -eq $null) {
        # install psget
        (New-Object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
    }
}

function installModule($moduleName) {
    if ((Get-Module $moduleName) -eq $null) {
        ensurePsGetExists

        Install-Module $moduleName
    }
}

function unzipTo($destinationFile, $destinationFolder) {
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    if (Test-Path $destinationFolder){
        rmdir -recurse -force $destinationFolder
    }
    [System.IO.Compression.ZipFile]::ExtractToDirectory($destinationFile, $destinationFolder)
}

function downloadPsReadLine {
    $moduleDir = "[System.IO.Path]::GetDirectoryName($profile)\Modules"
    $zipFile = "$moduleDir\PSReadLine.zip"

    (New-Object Net.WebClient).DownloadFile('https://github.com/lzybkr/PSReadLine/raw/master/PSReadline.zip', $zipFile)

    unzipTo $zipFile "$moduleDir\PSReadLine"
}

installModule pscx
installModule Find-String
installModule psake

downloadPsReadLine
