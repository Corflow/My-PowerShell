function PING-HOST
{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Computer to PING
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("Host", "HostName", "Node", "Computer")]
        [string[]]$ComputerName,

        [switch]$Forever
    )

    Begin
    {
    }
    Process
    {
        if($Forever)
        {
            foreach($computer in $ComputerName)
            {
                while($true)
                {
                Test-Connection $computer |
                select @{n='Time';E={[dateTime]::Now}}, 
                @{N='Destination';E={$_.address}}, 
                @{N='Time(ms)';E={$_.ResponseTime}}, 
                IPV4Address, Replysize
                }
            }
        }
        foreach($computer in $ComputerName)
            {
                Test-Connection $computer -count 1 |
                select @{N='Time';E={[dateTime]::Now}},
                @{N='Destination';E={$_.address}},
                @{N='Time(ms)'; E={$_.ResponseTime}},
                IPV4Address, Replysize             
             }
    }
    End
    {
    }
}