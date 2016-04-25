function Get-IISVersion
{
<#
.Synopsis
Queries the remote computers installed IIS version.
.EXAMPLE
$POD0 = Get-Content \\bna-vm-fs2\Public\_\Servers\PrimeSuite\Prod_Web_POD0.txt

PS C:\> Get-IISVersion $POD0
BNA-PR-GW-WEB01.HWWIN.local is running IIS Version 7.5
BNA-PR-GW-WEB02.HWWIN.local is running IIS Version 7.5
BNA-PR-GW-WEB03.HWWIN.local is running IIS Version 7.5
BNA-PR-GW-WEB04.HWWIN.local is running IIS Version 7.5

.EXAMPLE
PS C:\> Get-IISVersion BNA-PR-BIZ03
BNA-PR-BIZ03 is running IIS Version 7.5
#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        [string]
        $ErrorLog = 'C:\Logs\IIS-Version.log'
    )

    Begin
    {
    }
    Process
    {
        foreach ($computer in $computerName)
        {

    $version = Invoke-Command -ComputerName $Computer -scriptblock {$(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\).VersionString}
    
    Write-Output "$computer is running IIS $Version"
        }
    }
    End
    {
    }
}