function Get-SystemInfo
{
<#
.SYNOPSIS
Retrieves key system version and model information from one to fifty computers.
.DESCRIPTION
Get-SystemInfo uses Windows Management Instrumentation (WMI) to retrieve information from one or more computers.
Specify computers by name or by IP address.
.PARAMETER ComputerName
One or more computer names or IP addresses, up to a maximum of 50.
.PARAMETER LogErrors
Specify this switch to create a text log file of computers that could not be queried.
.PARAMETER ErrorLog
When used with -LogErrors, specifies the file path and name to which failed computer names will be written. 
Defaults to C:\Logs\Get-SystemInfo.txt.
.EXAMPLE
PS C:\> $POD0 = Get-Content \\bna-vm-fs2\Public\_\Servers\PrimeSuite\Prod_Web_POD0.txt

PS C:\> Get-SystemInfo $POD0 | Format-Table -AutoSize

OS Version                                 Service Pack OS Build Model                   LastBootTime         ComputerName                Manufacturer
----------                                 ------------ -------- -----                   ------------         ------------                ------------
Microsoft Windows Server 2008 R2 Standard             1 6.1.7601 VMware Virtual Platform 1/24/2016 8:00:32 PM BNA-PR-GW-WEB01.HWWIN.local VMware, Inc.
Microsoft Windows Server 2008 R2 Standard             1 6.1.7601 VMware Virtual Platform 1/24/2016 8:00:37 PM BNA-PR-GW-WEB02.HWWIN.local VMware, Inc.
Microsoft Windows Server 2008 R2 Standard             1 6.1.7601 VMware Virtual Platform 1/24/2016 8:00:28 PM BNA-PR-GW-WEB03.HWWIN.local VMware, Inc.
Microsoft Windows Server 2008 R2 Standard             1 6.1.7601 VMware Virtual Platform 1/24/2016 8:00:28 PM BNA-PR-GW-WEB04.HWWIN.local VMware, Inc.
.EXAMPLE
PS C:\> Get-SystemInfo localhost


OS Version   : Microsoft Windows 7 Enterprise 
Service Pack : 1
OS Build     : 6.1.7601
Model        : Latitude E7450
LastBootTime : 2/1/2016 8:02:13 AM
ComputerName : localhost
Manufacturer : Dell Inc.
.EXAMPLE
PS C:\> Get-SystemInfo -ComputerName NotOnline -LogErrors
WARNING: Failed to query NotOnline with the following error:
                The RPC server is unavailable. (Exception from HRESULT: 0x800706BA)
WARNING: Errors logged to C:\Logs\Get-SystemInfo.log
#>
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   HelpMessage="Computer name or IP address")]
        [ValidateCount(1,50)]
        [Alias('hostname')]
        [string[]]$ComputerName,
        
        [string]$ErrorLog = 'C:\Logs\Get-SystemInfo.log',

        [switch]$LogErrors

     )

    Begin
    {
        Write-Verbose "Error Log will be $ErrorLog"
        $Date = Get-Date

    }

    Process
    {

        foreach ($computer in $ComputerName)
        {
        Write-Verbose "Querying $computer"

            Try
                {
                $everything_ok = $true

                $os = Get-WmiObject -Class Win32_OperatingSystem `
                        -ComputerName $computer `
                        -erroraction Stop
                } 
            Catch
                {
                $everything_ok = $false
                Write-Warning "Failed to query $computer with the following error:
                $_"
                    if ($LogErrors)
                    {
                    Write-Output "$Date - $computer was unable to be reached. Error = $_" | Out-File $ErrorLog -Append
                    Write-Warning "Errors logged to $ErrorLog"
                    }
                }

            if ($everything_ok)
                {
                $comp = Get-WmiObject -Class Win32_ComputerSystem `
                            -ComputerName $computer
                $bios = Get-WmiObject -Class Win32_BIOS `
                            -ComputerName $computer

                $props = @{ 'ComputerName'=$computer;
                            'OS Version'=$os.Caption;
                            'OS Build'=$os.version;
                            'Service Pack'=$os.ServicePackMajorVersion;
                            'Manufacturer'=$comp.manufacturer;
                            'Model'=$comp.model
                            'LastBootTime'=($os.ConvertToDateTime($os.LastBootupTime));
                            }
                }

            Write-Verbose "Query on $computer is complete."

            $obj = New-Object -TypeName PSObject -Property $props
            $obj.PSObject.TypeNames.Insert(0,'MOL.SystemInfo')                                         
            Write-Output $obj


            }
    }

    End
    {
    }
}


cls

#$POD8 = Get-Content "C:\Users\Steve.Ross\Desktop\Servers\Prod_Web_POD8.txt"
#Get-SystemInfo -ComputerName $POD8 -ErrorLog POD8.log
#Get-SystemInfo -ComputerName Dummy -ErrorLog Dummy.log
#Get-SystemInfo -ComputerName localhost -Verbose

Get-SystemInfo -ComputerName bna-pr-gw-web01