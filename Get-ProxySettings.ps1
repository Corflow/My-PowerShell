Function Get-ProxySetting
{            
[CmdletBinding()]            
    Param(
    [string[]]$ComputerName
    )            
    Begin{}            
    
    Process 
    {
        foreach($Computer in $ComputerName)
        {
        
        $binval = Invoke-Command $Computer {(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name WinHttpSettings).WinHttPSettings}
        $proxylength = $binval[12]            

        if ($proxylength -gt 0) 
        {

        $proxy = -join ($binval[(12+3+1)..(12+3+1+$proxylength-1)] | % {([char]$_)})            
        $bypasslength = $binval[(12+3+1+$proxylength)]            

            if ($bypasslength -gt 0) 
            {            

            $bypasslist = -join ($binval[(12+3+1+$proxylength+3+1)..(12+3+1+$proxylength+3+1+$bypasslength)] | % {([char]$_)})            

            }# End If Bypass Length Greater Than 0.
        
            else 
            {            
            
            $bypasslist = '(none)'        
            
            }# End Else      
       
       Write-Host "
       Current WinHTTP proxy settings for $Computer :`n" -ForegroundColor Red
       '    Proxy Server(s): {0}' -f $proxy            
       '    Bypass List    : {0}' -f $bypasslist            
        
        }# End If Proxy Length Greater Than 0.
    
    else 
    {            
     
    Write-Host "
    Current WinHTTP proxy settings for $Computer`n"

    Write-Host "Direct access (no proxy server)." -ForegroundColor Green
         
        }# End Else = No Proxy Settings
    }# End Foreach            
}            
End{}            
} 