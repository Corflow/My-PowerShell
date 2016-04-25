# Check WmiObject Classes
Clear-Host
$Type = "Disk" 
Get-WmiObject -List | Where-Object {$_.name -Match $Type}

Get-WmiObject -List Win32_perf* | sort Name | select Name

# PowerShell cmdlet to display Logical Disk information
Clear-Host
Get-WmiObject Win32_logicaldisk | Format-Table -auto
Get-WmiObject -query "Select * from Win32_logicaldisk" |Ft
