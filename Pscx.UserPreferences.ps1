# ---------------------------------------------------------------------------
# Customized PSCX settings...
#
#     Import-Module Pscx -arg "$(Split-Path $profile -parent)\Pscx.UserPreferences.ps1"
#
# ---------------------------------------------------------------------------
@{
    ShowModuleLoadDetails = $false
    CD_GetChildItem = $false
    CD_EchoNewLocation = $true
    TextEditor = 'gvim.exe'
    PageHelpUsingLess = $true
    FileSizeInUnits = $true
                                      
	ModulesToImport = @{
		CD                = $false
		DirectoryServices = $true
		FileSystem        = $true
		GetChildItem      = $false
		GetHelp           = $true
		Net               = $true
		Prompt            = $false
		TabExpansion      = $false
		TranscribeSession = $false
		Utility           = $true
		Vhd               = $true

        # disabled because of issues with PowerShell v3
		Wmi               = $false
	}    
}
