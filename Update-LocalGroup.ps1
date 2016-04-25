Function Update-LocalGroup
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
        # Computer with group who you want to add memebers to.
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$ComputerName = (Read-Host 'Enter computer name or press <Enter> for localhost'),

        $Group = (Read-Host 'Enter local group name'),

        $Domain = (Read-Host 'Enter domain name'),

        $User = (Read-Host 'Enter user name'),

        [switch]$Add=$true,

        [switch]$Remove
    )

    Begin
    {
    }
    Process
    {

    if ($ComputerName -eq "") {$ComputerName = "$env:COMPUTERNAME"}
    
        foreach($Computer in $ComputerName)
        {

            if($Remove)
            {
            $confirm = Read-Host "Are you sure you want to remove the user $Domain\$User from local group $Group on computer ${Computer}? `n [Y] Yes [N] No (default is 'N')" 
                if ($confirm -eq "Y") 
                {  
                $get = [ADSI]"WinNT://$computer/$Group"
                $get.psbase.Invoke("Remove",([ADSI]"WinNT://$Domain/$User").path) 
                Write-Host ""
                Write-Host "User $Domain\$User has been removed from the local group $Group on computer $Computer." -ForegroundColor Yellow
                Write-Host ""
                Invoke-Command {net localgroup $Group}
                }#End Confirmation and group change block.
            }#End remove block.

            elseif($Add)
            {
            $confirm = Read-Host "Are you sure you want to add the user $Domain\$User to the local group $Group on computer ${$computer}? `n [Y] Yes [N] No (default is 'N')" 
                if ($confirm -eq "Y") 
                {
                $get = [ADSI]"WinNT://$computer/$Group"

                $get.psbase.Invoke("Add",([ADSI]"WinNT://$Domain/$User").path)
                Write-Host ""
                Write-Host "User $Domain\$User has been added to the local group $Group on computer $Computer." -ForegroundColor Green
                Write-Host ""
                Invoke-Command {net localgroup $Group}
                }#End Confirmation and group change block.
            }#End add block.

            }#End Foreach block.

        }#End Process block.


    End
    {
    }
}#End Function.
