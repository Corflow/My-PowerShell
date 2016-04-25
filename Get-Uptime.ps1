Function Get-Uptime 
{
<#
.Synopsis
   Gets the last time a server or swervers have been rebooted and the uptime.
   Uptime = Days.Hours:Minutes:Seconds
.EXAMPLE
PS C:\> Get-LastBoot localhost

Computer Name Last Boot Time      Uptime  
------------- --------------      ------  
localhost     2/1/2016 8:02:13 AM 00:30:16
.EXAMPLE
PS C:\> Get-Uptime BNA-PR-MID01

BNA-PR-MID01 has been up for 24 Days, 18 Hours, 24 Minutes, 26 Seconds
.EXAMPLE
PS C:\> Get-Uptime $PrimeSuite_POD0

BNA-PR-GW-WEB01.HWWIN.local has been up for 24 Days, 18 Hours, 20 Minutes, 54 Seconds

BNA-PR-GW-WEB02.HWWIN.local has been up for 24 Days, 18 Hours, 20 Minutes, 50 Seconds

BNA-PR-GW-WEB03.HWWIN.local has been up for 24 Days, 18 Hours, 21 Minutes, 01 Seconds

BNA-PR-GW-WEB04.HWWIN.local has been up for 24 Days, 18 Hours, 21 Minutes, 04 Seconds   
#>
       param ([string[]]$ComputerName=$env:COMPUTERNAME)
       foreach($Computer in $ComputerName)
       {
       $Uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
       $LastBootUpTime = $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
       $Time = (Get-Date) - $LastBootUpTime
       Write-Host ""
       "$computer has been up for {0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds" -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
       }
}