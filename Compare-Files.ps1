cls

$ComputerName = "P-DB-GP-01"


foreach ($Computer in $ComputerName)
    {

        Invoke-Command -ComputerName $Computer -Credential $creds {
    
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
        PS C:\> Get-SystemInfo $PrimeSuite_POD0 | Format-Table -AutoSize

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
                        $proc = Get-WmiObject -class win32_processor
                        $disk = Get-WmiObject Win32_logicaldisk -ComputerName $Computer -Filter 'MediaType =12' `
                            
                        <#$props = @{ 'ComputerName'=$computer;
                                    'OS Version'=$os.Caption;
                                    'OS Build'=$os.version;
                                    'Service Pack'=$os.ServicePackMajorVersion;
                                    'Manufacturer'=$comp.manufacturer;
                                    'Model'=$comp.model
                                    'LastBootTime'=($os.ConvertToDateTime($os.LastBootupTime));
                                    }#>
                        @{'Computer Name' = $computer}
                        @{'OS Version'= ($os).Caption}
                        @{'OS Build'= ($os).version}
                        @{'Service Pack'= ($os).ServicePackMajorVersion}
                        "----"
                        @{'Manufacturer'=($comp).manufacturer}
                        @{'Model'= ($comp).model}
                        "----"
                        @{'CPU Type'= ($proc).Name}
                        @{'CPU Speed (GHz)' = ($proc).MaxClockSpeed/1000}
                        @{'CPU Physical Cores' = ($proc).NumberOfCores}
                        @{'CPU Logical Cores' = ($proc).NumberOfLogicalProcessors}
                        @{'CPU 32/64 bit' = ($proc).AddressWidth}
                        "----"
                        @{'Installed Memory (Gb)' = ([math]::Round(($comp).TotalPhysicalMemory/1gb))}
                        "----"
                        Get-DiskInfo $computer
                        }

                    Write-Verbose "Query on $computer is complete."

                    #$obj = New-Object -TypeName PSObject -Property $props
                    #$obj.PSObject.TypeNames.Insert(0,'MOL.SystemInfo')                                         
                    #Write-Output $obj



                    }
            }

            End
            {
            }
            }


            ###############################################################

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
        PS C:\> Get-DiskInfo $PrimeSuite_POD0 | Format-Table

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

                #[System.Management.Automation.CredentialAttribute()]$Credentials,

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
                        | select @{Name='Drive Letter';Expression={$_.DeviceID}}, 
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

            ###############################################################
        
        Get-SystemInfo -ComputerName localhost

            } | Out-File -FilePath C:\ps\Out\Output\P-DB-GP-01.txt -Append
}#End Foreach