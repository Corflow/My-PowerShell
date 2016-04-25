function Sweep-Subnet
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
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$IPAddress="0.0.0.",

        [int]$StartIP,
        [int]$EndIP

    )

    Begin
    {
    }
    Process
    {
    $StartIP..$EndIP | where {
    Test-Connection "$IPAddress$_" -Count 1 -ErrorAction SilentlyContinue
    } | foreach { "$IPAddress$_" }
    }
    End
    {
    }
}

cls

Sweep-Subnet -IPAddress 10.4.1. -StartIP 56 -EndIP 105