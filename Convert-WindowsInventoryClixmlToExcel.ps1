<#
	.SYNOPSIS
		Writes an Excel file containing the Database Engine information in a SQL Server Inventory file created by Get-WindowsInventoryToClixml.ps1.

	.DESCRIPTION
		This script loads a Windows Inventory file created by Get-WindowsInventoryToClixml.ps1 and calls the Export-WindowsInventoryToExcel function in the WindowsInventory module to write an Excel file containing the Windows Operating System information from the inventory.

		Microsoft Excel 2007 or higher must be installed in order to write the Excel file.
		
	.PARAMETER  FromPath
		The literal path to the XML file created by Get-WindowsInventoryToClixml.ps1.
		
	.PARAMETER  ToPath
		Specifies the literal path where the Excel file will be written. This path (but not the filename) must exist prior to executing this script.
		
		If not specified then ToPath defaults to the same directory specified by the FromPath paramter.
		
		Assuming the XML file specified in FromPath is named "Windows Inventory.xml" then the Excel file will be written to "Windows Inventory.xlsx"
		
	.PARAMETER  ColorTheme
		An Office Theme Color to apply to each worksheet. If not specified or if an unknown theme color is provided the default "Office" theme colors will be used.
		
		Office 2013 theme colors include: Aspect, Blue Green, Blue II, Blue Warm, Blue, Grayscale, Green Yellow, Green, Marquee, Median, Office, Office 2007 - 2010, Orange Red, Orange, Paper, Red Orange, Red Violet, Red, Slipstream, Violet II, Violet, Yellow Orange, Yellow
		
		Office 2010 theme colors include: Adjacency, Angles, Apex, Apothecary, Aspect, Austin, Black Tie, Civic, Clarity, Composite, Concourse, Couture, Elemental, Equity, Essential, Executive, Flow, Foundry, Grayscale, Grid, Hardcover, Horizon, Median, Metro, Module, Newsprint, Office, Opulent, Oriel, Origin, Paper, Perspective, Pushpin, Slipstream, Solstice, Technic, Thatch, Trek, Urban, Verve, Waveform

		Office 2007 theme colors include: Apex, Aspect, Civic, Concourse, Equity, Flow, Foundry, Grayscale, Median, Metro, Module, Office, Opulent, Oriel, Origin, Paper, Solstice, Technic, Trek, Urban, Verve
		
	.PARAMETER  ColorScheme
		The color theme to apply to each worksheet. Valid values are "Light", "Medium", and "Dark". 
		
		If not specified then "Medium" is used as the default value .

	.PARAMETER  LoggingPreference
		Specifies the logging verbosity to use when writing log entries.
		
		Valid values include: None, Standard, Verbose, and Debug.
		
		The default value is "None"
		
	.PARAMETER  LogPath
		A literal path to a log file to write details about what this script is doing. The filename does not need to exist prior to executing this script but the specified directory does.
		
		If a LoggingPreference other than None is specified and this parameter is not specified then the file is named "Windows Inventory - [Year][Month][Day][Hour][Minute].log" and is written to your "My Documents" folder.

		
	.EXAMPLE
		.\Convert-WindowsInventoryClixmlToExcel.ps1 -FromPath "C:\Inventory\Windows Inventory.xml" 
		
		Description
		-----------
		Writes an Excel file for the Windows Operating System information contained in "C:\Inventory\Windows Inventory.xml" to "C:\Inventory\Windows Inventory.xlsx".
		
		The Office color theme and Medium color scheme will be used by default.
		
	.EXAMPLE
		.\Convert-WindowsInventoryClixmlToExcel.ps1 -FromPath "C:\Inventory\Windows Inventory.xml"  -ColorTheme Blue -ColorScheme Dark
		
		Description
		-----------
		Writes an Excel file for the Windows Operating System information contained in "C:\Inventory\Windows Inventory.xml" to "C:\Inventory\Windows Inventory.xlsx".
		
		The Blue color theme and Dark color scheme will be used.

	
	.NOTES
		Blue and Green are nice looking Color Themes for Office 2013

		Waveform is a nice looking Color Theme for Office 2010

	.LINK
		Get-WindowsInventoryToClixml.ps1		

#>
[cmdletBinding(SupportsShouldProcess=$false)]
param(
	[Parameter(Mandatory=$true)] 
	[alias('from')]
	[ValidateNotNullOrEmpty()]
	[string]
	$FromPath
	,
	[Parameter(Mandatory=$false)] 
	[alias('to')]
	[ValidateNotNullOrEmpty()]
	[string]
	$ToPath = [System.IO.Path]::ChangeExtension($FromPath, '.xlsx')
	, 
	[Parameter(Mandatory=$false)] 
	[alias('loglevel')]
	[ValidateSet('none','standard','verbose','debug')]
	[string]
	$LoggingPreference = 'none'
	,
	[Parameter(Mandatory=$false)] 
	[alias('log')]
	[ValidateNotNullOrEmpty()]
	[string]
	$LogPath = (Join-Path -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath ("Windows Inventory - " + (Get-Date -Format "yyyy-MM-dd-HH-mm") + ".log"))
	,
	[Parameter(Mandatory=$false)] 
	[alias('theme')]
	[string]
	$ColorTheme = 'office'
	,
	[Parameter(Mandatory=$false)] 
	[ValidateSet('dark','light','medium')]
	[string]
	$ColorScheme = 'medium' 
)


######################
# FUNCTIONS
######################

function Write-LogMessage {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Message
		,
		[Parameter(Position=1, Mandatory=$true)] 
		[alias('level')]
		[ValidateSet('information','verbose','debug','error','warning')]
		[System.String]
		$MessageLevel
	)
	try {
		if ((Test-Path -Path 'function:Write-Log') -eq $true) {
			Write-Log -Message $Message -MessageLevel $MessageLevel
		} else {
			Write-Host $Message
		}
	}
	catch {
		throw
	}
}


######################
# VARIABLES
######################
$ProgressId = Get-Random
$ProgressActivity = 'Convert-WindowsInventoryClixmlToExcel'
$ProgressStatus = $null

######################
# BEGIN SCRIPT
######################

# Import Modules that we need
Import-Module -Name LogHelper, WindowsInventory

# Set logging variables
Set-LogFile -Path $LogPath
Set-LoggingPreference -Preference $LoggingPreference

$ProgressStatus = "Starting Script: $($MyInvocation.MyCommand.Path)"
Write-LogMessage -Message $ProgressStatus -MessageLevel Information
Write-Progress -Activity $ProgressActivity -PercentComplete 0 -Status $ProgressStatus -Id $ProgressId

$ProgressStatus = "Loading inventory from '$FromPath'"
Write-LogMessage -Message $ProgressStatus -MessageLevel Information
Write-Progress -Activity $ProgressActivity -PercentComplete 0 -Status $ProgressStatus -Id $ProgressId

Import-Clixml -Path $FromPath | ForEach-Object {
	if ($_.ScanSuccessCount -gt 0) {
		$ProgressStatus = 'Writing Windows Inventory To Excel'
		Write-Progress -Activity $ProgressActivity -PercentComplete 50 -Status $ProgressStatus -Id $ProgressId
		Export-WindowsInventoryToExcel -WindowsInventory $_ -Path $ToPath -ColorTheme $ColorTheme -ColorScheme $ColorScheme
	} else {
		Write-LogMessage -Message 'No machines found!' -MessageLevel Warning
	}
}

$ProgressStatus = "End Script: $($MyInvocation.MyCommand.Path)"
Write-LogMessage -Message $ProgressStatus -MessageLevel Information
Write-Progress -Activity $ProgressActivity -PercentComplete 100 -Status $ProgressStatus -Id $ProgressId -Completed

# Remove Variables
Remove-Variable -Name ProgressId, ProgressActivity, ProgressStatus

# Remove Modules
Remove-Module -Name WindowsInventory, LogHelper

# Call garbage collector
[System.GC]::Collect()