function Get-IPInfo
{
<#
.Synopsis
   Get's IP information from 1 to 50 computers. 
.DESCRIPTION
   Use this function to gather the IP Address information on 1 or up to 50 computers.
.EXAMPLE
PS C:\> Get-IPInfo localhost


PSComputerName  : 94200-2-9097
IP Address      : 10.114.50.90
IP Subnet       : 255.255.255.0
Default Gateway : 10.114.50.1
MACAddress      : C4:8E:8F:FC:83:69
Description     : Dell Wireless 1560 802.11ac
.EXAMPLE
PS C:\> Get-IPInfo localhost | Format-Table

PSComputerName IP Address   IP Subnet     Default Gateway MACAddress        Description                
-------------- ----------   ---------     --------------- ----------        -----------                
94200-2-9097   10.114.50.90 255.255.255.0 10.114.50.1     C4:8E:8F:FC:83:69 Dell Wireless 1560 802.11act
#>
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   HelpMessage="Computer name or IP address")]
        [ValidateCount(1,50)]
        [Alias('hostname')]
        [string[]]$ComputerName
    )
    Begin
    {
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {

        Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'True'" -ComputerName $Computer |
        Select PSComputername,
        @{Name = "IP Address";Expression = {
        [regex]$rx1 = "(\d{1,3}(\.?)){4}"
        $rx1.matches($_.IPAddress).Value}},
        @{Name = "IP Subnet";Expression = {
        [regex]$rx2 = "(\d{1,3}(\.?)){4}"
        $rx2.matches($_.IPSubnet).Value}},
        @{Name = "Default Gateway";Expression = {
        [regex]$rx2 = "(\d{1,3}(\.?)){4}"
        $rx2.matches($_.DefaultIPGateway).Value}},MACAddress,Description

        }
    }
    End
    {
    }
}