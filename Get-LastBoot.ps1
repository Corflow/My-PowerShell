function Get-LastBoot
{
<#
.Synopsis
   Gets the last time a server or swervers have been rebooted. 
.EXAMPLE
PS C:\> Get-LastBoot localhost

Computer Name Last Boot Time     
------------- --------------     
localhost     2/1/2016 8:02:13 AM
.EXAMPLE
PS C:\> Get-LastBoot BNA-PR-MID01

Computer Name Last Boot Time      
------------- --------------      
BNA-PR-MID01  1/24/2016 8:00:35 PM
.EXAMPLE
PS C:\> Get-LastBoot $POD7

Computer Name               Last Boot Time      
-------------               --------------      
BNA-PR-GW-WEB71.HWWIN.local 1/30/2016 3:27:16 AM
BNA-PR-GW-WEB72.HWWIN.local 1/30/2016 3:27:46 AM
BNA-PR-GW-WEB73.HWWIN.local 1/30/2016 3:28:12 AM
BNA-PR-GW-WEB74.HWWIN.local 1/30/2016 3:28:51 AM
#>
[cmdletbinding()]
    param
    (
        [string[]]$ComputerName = 'localhost',

        [string]$ErrorLog = "C:\Logs\Get-SysInfo"
    )
    
    Begin
    {
    }
    
    Process
    {
        foreach ($Computer in $ComputerName)
        {
        Try
            {

            $os = Get-WmiObject Win32_OperatingSystem `
                -ComputerName $Computer
            $comp = Get-WmiObject Win32_ComputerSystem `
                -ComputerName $Computer

                $props = 
                @{
                'Computer Name' = $Computer;
                'Last Boot Time' = ($os.ConvertToDateTime($os.LastBootUpTime));
                }

                $obj = New-Object -TypeName PSObject -Property $props
                               
                Write-Output $obj

            }

            Catch
            {
            }
        }
    }

    End
    {
    }

 }

#$web = Get-Content "C:\Users\Steve.Ross\Desktop\Servers\Prod_Web.txt"
#$POD8 = Get-Content "C:\Users\Steve.Ross\Desktop\Servers\Prod_Web_POD8.txt"
Get-LastBoot -ComputerName localhost