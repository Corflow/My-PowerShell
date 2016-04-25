function IIS-Stop
{
    
    Param (
    [string[]] $ComputerName
    )

        foreach($Computer in $ComputerName)
        {

        Invoke-Command -ComputerName $Computer -ScriptBlock {iisreset /STOP}

        }
        
}

function IIS-Start
{
    
    Param (
    [string[]] $ComputerName
    )

        foreach($Computer in $ComputerName)
        {

        Invoke-Command -ComputerName $Computer -ScriptBlock {iisreset /START}

        }
}

function IIS-Reset
{
    
    Param (
    [string[]] $ComputerName
    )

        foreach($Computer in $ComputerName)
        {

        Invoke-Command -ComputerName $Computer -ScriptBlock {iisreset}

        }
}
