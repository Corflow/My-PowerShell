function Add-Zip  # usage: Get-ChildItem $folder | Add-Zip $zipFullName 
{
    param([string]$zipfilename)
	
	Write-Host "Please wait while your file is being zipped..."
    
	if(!(test-path($zipfilename)))
    {
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfilename).IsReadOnly = $false    
    }
    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)
    foreach($file in $input) 
    { 
        $zipPackage.CopyHere($file.FullName)
        do {
            Start-sleep 2
        } until ( $zipPackage.Items() | select {$_.Name -eq $file.Name} )
    }
		Write-Host "Zip process completed..."
}
$timestamp = Get-Date -Format s | foreach {$_ -replace ":", "."}
#$BackupTo = ("\\localhost\D$\Backup\" + 'Application' + '_' + $timestamp + '.zip')
#$BackupFrom = "\\localhost\c$\inetpub\wwwroot\EligibilityAdminTest"

$sw = [Diagnostics.Stopwatch]::StartNew()
Get-ChildItem -Path $BackupFrom | Add-Zip $BackupTo
$sw.Stop()
Write-Host "It took" $sw.Elapsed.TotalSeconds "seconds to complete."