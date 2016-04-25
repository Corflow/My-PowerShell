<#HELP FILE#
.Synopsis
This is an application used to deploy code for the Eligibility services. 
.Description
With this tool you can select different environments and services to deploy to.
#>

###################################################################################

############### Pop-up Window to Select an Environment to Deploy to ###############

###################################################################################

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select an Environment"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$selectedEnvironment=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$selectedEnvironment=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select an Environment:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[Void] $objListBox.Items.Add("____Default Environment")
[void] $objListBox.Items.Add("QA")
[void] $objListBox.Items.Add("BPO")
[void] $objListBox.Items.Add("SIT")
[void] $objListBox.Items.Add("DAVE")
[void] $objListBox.Items.Add("PROD")


$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

###################################################################################

############### Pop-up Window to Select a Service to Deploy to ####################

###################################################################################

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select an Application"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$selectedApplication=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$selectedApplication=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select an Environment:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("EligibilityAdmin")
[void] $objListBox.Items.Add("EligibilityServices\TCHS Eligibility Export Service")
[void] $objListBox.Items.Add("EligibilityServices\TCHS Eligibility Import Service")
[void] $objListBox.Items.Add("EligibilityServices\TCHS.Eligibility.JobFrameworkService")
#G:\Builds\Nolio\BPO\EligibilityServices\TCHS.Eligibility.JobFrameworkService

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

###################################################################################

###################### This is where I defined my Variables #######################

###################################################################################

$destinationServerName = Get-Content c:\servers.txt
$timestamp = Get-Date -Format s | foreach {$_ -replace ":", "."}
$filename = @("\\$destinationServerName\D$\Backup\" + $selectedApplication + '_' + $timestamp + '.zip')
$selectedEnvironment
$selectedApplication
$sourceFilePath = "\\bna-ts-eli01.HWWIN.local\builds\Nolio\$selectedEnvironment\$selectedApplication\Latest\*" 
$sourceFilePath

###################################################################################

###################### This is where I defined my Functions #######################

###################################################################################

function Backup-Contents{
	[CmdletBinding()]
	Param(
        [string]$zipfilename
		)
		(
        #Switch to turn on Error logging
        [Switch]$ErrorLog,
        [String]$LogFile = 'c:\errorlog.txt'
    	)

    if(-not (test-path($zipfilename)))
    {
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfilename).IsReadOnly = $false  
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)
    #$zipPackage.CopyHere($input.FullName)
	

    foreach($file in $input) 
    { 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 500
    }

}

function Delete-Contents{
	[CmdletBinding()]
	Param(
	[string] $webDir
	)
	{
	$deleted = @()
	Get-ChildItem $webDir -Recurse | 
	ForEach-Object {
	  $deleted += $_.FullName
	  $_
	} | Remove-Item -Force -ErrorAction SilentlyContinue

	}

}

function Remove-EmptyFolders{
	[CmdletBinding()]
	Param($folder)
{
	  Get-ChildItem $folder | Where-Object { $_.PSIsContainer } | ForEach-Object {
	    $path = $_.FullName
	    Remove-Emptyfolders $path
	    if ( @(Get-ChildItem $path -Recurse | Where-Object { -not $_.PSIsContainer}).Length -eq 0 ) {
	      $deleted += $path
	      Remove-Item $path -Recurse -Force
	    }
	  }
}
}

function Stop-IIS{
	[CmdletBinding()]
	Param(
	[string]$siteName)
	{
	[System.Reflection.Assembly]::LoadFrom( "C:\windows\system32\inetsrv\Microsoft.Web.Administration.dll" )
	Import-Module WebAdministration

	$siteName = New-Object microsoft.web.administration.servermanager
	$siteName.Sites
	
	}

	if ($selectedApplication -eq 'EligibilityAdmin')
	{
	$selectedAppPath = 'c$\inetpub\wwwroot\EligibilityAdminTest'
	}
	elseif ($selectedApplication -eq '"EligibilityServices\TCHS Eligibility Import Service"')
	{
	$selectedAppPath = '\\$destionationServerName\c$\Program Files (x86)\Take Care Health Systems\TCHS Eligibility Import Service\*'
	}
	elseif ($selectedApplication -eq '"EligibilityServices\TCHS Eligibility Export Service"')
	{
	$selectedAppPath = '\\$destionationServerName\c$\Program Files (x86)\Take Care Health Systems\TCHS Eligibility Export Service\*'
	}

}

###################################################################################

######################## This is where I Execute the Code #########################

###################################################################################
if{
(($selectedEnvironment -ne $null) -and ($selectedApplication -ne $null))
	{
	$destinationFilePath = "\\$destinationServerName\$selectedAppPath\"
	dir $destinationFilePath | BackupContents $filename 
	DeleteContents($destinationFilePath) 
	Remove-EmptyFolders $destinationFilePath -folder *
	#[string]$destinationFilePath = $selectedAppPath | ForEach-Object{$_ -replace "\*", ""}
	$destinationFilePath
	$cred = Get-Credential # input your username and password of $SourceServerName here
	Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Recurse
	
	
	}
}

else{
	{
	Write-Host "Steps were not completed"
	$selectedEnvironment = $null
	$selectedApplication = $null
	$selectedAppPath = $null
	$SourceFilePath = $null
	EXIT 
	}
}

###################################################################################

##################### This is where I Clean Up the Code ###########################

###################################################################################
END{
$selectedEnvironment = $null
$selectedApplication = $null
$selectedAppPath = $null
$SourceFilePath = $null
$destinationFilePath = $null
$destinationServerName = $null
}
