function Get-Nap
{
    [CmdletBinding()]
    Param
    (
        #nap time in minutes
        [int]$Minutes = 1,
 
        #define the wakeup time
        $wake = (Get-Date).AddMinutes($Minutes)
    )
    Begin
    {
    }
    Process
    {
        #loop until the time is >= the wake up time
        do 
        {
        cls
        Write-host "Ssshhhh...." -ForegroundColor Cyan
 
        #trim off the milliseconds
        write-host ($wake - (Get-Date)).ToString().Substring(0,8) -NoNewline
 
        Start-Sleep -Seconds 1
 
        } Until ( (Get-Date) -ge $wake)
 
        #Play wake up music
        [console]::Beep(392,1000)
        [console]::Beep((329.6*2),1000)
        [console]::Beep(523.2,1000)
 
        Write-Host "`nWAKE UP SLEEPY HEAD!" -ForegroundColor Yellow
    }
    End
    {
    }
}