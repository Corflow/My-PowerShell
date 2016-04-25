Function Get-CompInfo{
    [CmdletBinding()]
    Param(
        #Want to support multiple computers
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    HelpMessage= 'Provide one or more computer name')]
        [String[]]$ComputerName,

        #Switch to turn on Error logging
        [Switch]$ErrorLog,
        [String]$LogFile = 'c:\errorlog.txt'
    )
    Begin{
        If($errorLog){
                Write-Verbose 'Error logging turned on'
            } Else {
                Write-Verbose 'Error logging turned off'
            }
            Foreach($Computer in $ComputerName){
                Write-Verbose "Computer: $Computer"
            }    
    }
    Process{
        foreach($Computer in $ComputerName){
            $os=Get-Wmiobject -ComputerName $Computer -Class Win32_OperatingSystem
            $DiskC=Get-WmiObject -ComputerName $Computer -class Win32_LogicalDisk -filter "DeviceID='c:'"
            $DiskD=Get-WmiObject -ComputerName $Computer -class Win32_LogicalDisk -filter "DeviceID='d:'"
            $CPUSockets=Get-WmiObject -ComputerName $Computer -class Win32_Processor
            $CPUCores=Get-WmiObject -ComputerName $Computer -class Win32_Processor
            $RAM=Get-WmiObject -ComputerName $Computer -class Win32_PhysicalMemory
            
            $Prop=[ordered]@{
                'ComputerName'=$computer;
                'OS Version'=$os.caption;
                'OS Build'=$os.buildnumber;
                'C:\ FreeSpace in GB'=$DiskC.freespace / 1gb -as [int]
                'D:\ FreeSpace in GB'=$DiskD.freespace / 1gb -as [int]
                'CPU Sockets'=($CPUSockets.NumberOfSockets | Measure-Object).Count + 1
                'CPU Cores'=($CPUCores.NumberOfCores | Measure-Object).Count
                'RAM in GB'=$RAM.Capacity / 1gb -as [int]

            }
        
        $obj=New-Object -TypeName PSObject -Property $Prop
        Write-Output $obj

        } 
    }
    End{}

}

