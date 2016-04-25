function Get-DotNetVersion
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
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName

    )

    Begin
    {
    }
    Process
    {
    foreach($Computer in $ComputerName)
        {
        Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
        Get-ItemProperty -name Version,Release -EA 0 |
        Where { $_.PSChildName -match '^(?!S)\p{L}'} | Select @{N="Computer Name";E={$Computer}}, @{N=".NET Component";E={$_.PSChildName}}, Version, Release
        }
    }
    End
    {
    }
}