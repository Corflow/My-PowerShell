function Get-DiskInfo
{
<#
.Synopsis
   Get's disk information from 1 to 50 computers. 
.DESCRIPTION
   Use this function to gather the physical and logical information from disks on 1 or up to 50 computers.
   Make sure to use the switches (LogicalDisk, PhysicalDisk or All) to select which disk to query.
.EXAMPLE
PS C:\> Get-DiskInfo localhost


PSComputerName  : 94200-2-9097
Drive Letter    : C:
Size (GB)       : 238
Free Space (GB) : 177
Free (%)        : 74

.EXAMPLE
PS C:\> Get-DiskInfo $POD0 | Format-Table -AutoSize

PSComputerName  Drive Letter Size (GB) Free Space (GB) Free (%)
--------------  ------------ --------- --------------- --------
BNA-PR-GW-WEB01 C:                  80              43       53
BNA-PR-GW-WEB01 D:                  40              21       52
BNA-PR-GW-WEB02 C:                  80              48       60
BNA-PR-GW-WEB02 D:                  40              27       69
BNA-PR-GW-WEB03 C:                  80              48       60
BNA-PR-GW-WEB03 D:                  40              28       71
BNA-PR-GW-WEB04 C:                  80              48       60
BNA-PR-GW-WEB04 D:                  40              28       71 

.EXAMPLE
PS C:\> Get-DiskInfo -ComputerName NotOnline
WARNING: Failed to query NotOnline with the following error:
                The RPC server is unavailable. (Exception from HRESULT: 0x800706BA)
#>
    [CmdletBinding()]
    
    Param
    (
        # Computer name or IP address of system you want to qyery.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Computer name or IP address",
                   Position=0)]
        [ValidateCount(1,50)]
        [string[]]$ComputerName,

        # Error Log for tracking issues. 
        [string]
        $ErrorLog = 'C:\Logs\Get-DiskInfo.log',

        [switch]$LogErrors

    )

        Begin
        {
        Write-Verbose "Error Log will be $ErrorLog"
        $Date = Get-Date
        }
        Process
        {
            foreach ($Computer in $ComputerName)
            {
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
                    Write-Output "$Date - $computer was unable to be reached. Error $_" | Out-File $ErrorLog -Append
                    Write-Warning "Errors logged to $ErrorLog"
                    }
                }
                
                if ($everything_ok)
                {                                                        
                Get-WmiObject Win32_logicaldisk -ComputerName $Computer -Filter 'MediaType =12' `
                | select PSComputerName, @{Name='Drive Letter';Expression={$_.DeviceID}}, 
                @{Name='Size (GB)';Expression={[math]::Round($_.Size/1GB)}}, 
                @{Name='Free Space (GB)';Expression={[math]::Round($_.Freespace/1GB)}},
                @{Name='Free (%)';Expression={[math]::Round($_.Freespace*100/$_.Size)}} 
                }
             }
        }          

        End
        {
        }
}

cls

Get-DiskInfo -ComputerName BNA-PR-MID01