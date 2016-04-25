$ComputerName = "$POD0"

foreach ($computer in $ComputerName)
{

        #$compinfo = @()
        $computerSystem = Get-WmiObject Win32_ComputerSystem -ComputerName $computer
        $computerBIOS = Get-WmiObject Win32_BIOS -ComputerName $computer
        $computerOS = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
        $computerCPU = Get-WmiObject Win32_Processor -ComputerName $computer
        $computerHDD = Get-WmiObject Win32_LogicalDisk -ComputerName $computer -Filter drivetype=3 
        $colItems = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computer -Filter "IpEnabled = TRUE"
# Build objects
ForEach($HDD in $computerHDD)
    {
    $compinfo += New-Object PSObject -property @{ 
        PCName = $computerSystem.Name 
        Manufacturer = $computerSystem.Manufacturer 
        Model = $computerSystem.Model 
        SerialNumber = $computerBIOS.SerialNumber 
        RAM = "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) 
        HDDSize = "{0:N2}" -f ($HDD.Size/1GB) 
        HDDFree = "{0:P2}" -f ($HDD.FreeSpace/$HDD.Size) 
        CPU = $computerCPU.Name 
        OS = $computerOS.caption 
        SP = $computerOS.ServicePackMajorVersion 
        User = $computerSystem.UserName 
        BootTime = $computerOS.ConvertToDateTime($computerOS.LastBootUpTime) 
        IP_Address = [string]$colItems.IpAddress 
        MAC_Address = [string]$colItems.MacAddress 
        Default_Gateway = [string]$colItems.DefaultIpGateway 
        DNS_Domain = $colItems.DNSDomain 
        DHCP_Enabled = $colItems.DHCPEnabled 
        }
    }
}

$compinfo | select -Property HDDFree ,HDDSize ,Ram ,OS ,CPU ,SP ,IP_Address,Mac_Address ,BootTime ,DHCP_Enabled