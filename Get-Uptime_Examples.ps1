function Get-SystemUpime
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
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        # Param2 help description
        [string]
        $ErrorLog
    )

        Begin
        {
        }
        Process
        {
        foreach ($Computer in $ComputerName)
            {
            $perfos=Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_System -ComputerName $Computer

            $boot=(Get-Date).AddSeconds(-$perfos.SystemUptime)

            $Uptime=(Get-Date)-$boot

            $Uptime.ToString()
            }
        }
        End
        {
        }
}

function Get-ProcessUptime
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        # Param2 help description
        [int]
        $ErrorLog
    )

        Begin
        {
        }
        Process
        {
          Get-Process | where {$_.StartTime} | select `
          Name, StartTime, @{Name="Runtime";Expression=`
          {(Get-Date)-$_.starttime}}  
        }
        End
        {
        }
}

Function Get-ServiceUptime 
{
    [cmdletbinding()]

    Param (
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$name="*",

    [ValidateNotNullOrEmpty()]
    [string]$computername=$env:computername
    )

    Write-Verbose ("Starting {0}" -f $myinvocation.mycommand)
    Try {
        if ($name -match "\*") {
            #filter out services not running or disabled
            #replace * with %
            $namefilter=$name.Replace("*","%")
            $filter="name like '$namefilter' AND ProcessID>0"
        }
        else {
            $filter="name='$name' AND ProcessID>0"
        }
        Write-Verbose ("Running filter {0} on {1}" -f $filter,$computername)
        $service=Get-WmiObject Win32_Service -filter $filter -computername $computername -erroraction Stop
    
        foreach ($svc in $service) {
            $proc=Get-WmiObject Win32_Process -filter "processID='$($svc.ProcessID)'" -computername $computername -erroraction Stop
            If ($proc) {
            Write-Verbose ("Retrieved {0} process" -f ($proc | measure-object).count)
            Write-Verbose ("Converting creation date {0} for {1}" -f $proc.CreationDate,$proc.Name)
            $started=$proc.ConvertToDateTime($proc.CreationDate)

            New-Object -TypeName PSObject -Property @{
              Name=$svc.Name
              Displayname=$svc.DisplayName
              StartMode=$svc.StartMode
              State=$svc.State
              Computername=$svc.__SERVER
              ProcessID=$svc.ProcessID
              Started=$Started
              Runtime=(Get-Date)-$started
            }
           } #if
       } #foreach
    } #try

    Catch {
        Write-Warning ("WMI command failed for {0} service on {1}. Exception {2}" -f $name,$computername.ToUpper(),$_.Exception.Message)
    }

    Write-Verbose ("Ending {0}" -f $myinvocation.mycommand)

}



### Some code I was working with ###

<#
## Example of getting the uptime of a single process. ##

$s=gwmi Win32_Service -Filter "name='lanmanserver'"
$p=gwmi Win32_Process -Filter "ProcessID='$($s.ProcessID)'"

$started=$p.ConvertToDateTime($p.CreationDate)
$runtime=(Get-Date)-$started

$runtime.ToString()
#>

<#
## Example of getting the uptime of a system or multiple systems. ##

gwmi Win32_OperatingSystem -ComputerName $POD0 `
| select @{Name="Computer Name";Expression={$_.CSName}},
@{Name="Last Boot Up";Expression={$_.ConvertToDateTime($_.LastBootUpTime)}},
@{Name="Uptime (Days.Hours:Minutes)";Expression={(Get-Date)-($_.ConvertToDateTime($_.LastBootUpTime))}}
#----------------------- ANOTHER WAY TO DO IT ---------------------------------------------------------#
gwmi Win32_PerfFormattedData_PerfOS_System -ComputerName $POD0 `
| select @{Name="Computer Name";Expression={$_.__SERVER}},
@{Name="Last Boot";Expression={(Get-Date).AddSeconds(-($_.SystemUpTime))}},
@{Name="Uptime (Days.Hours:Minutes:Seconds)";Expression={(Get-Date)-(Get-Date).AddSeconds(-$_.Systemuptime)}}

## ** The Performance Counter takes a little longer to run so this command is slower than the first one. ** ##
#>

<#
## Example of getting the uptime of processes. ##

$sb = 
{
Get-Process | Where {$_.StartTime} `
| select Name, ID, SatrtTime, @{Name="Runtime";Expression={(Get-date)-$_.StartTime}}
}

&$sb | sort -Property Runtime | ft -auto

#>

<#
## Example of getting the uptime of a specific service using wildcard. ##

Get-ServiceUptime *MOVE* -computername BNA-PR-MID01 `
| sort Runtime | select ComputerName, Displayname, Started, Runtime, ProcessID | Format-Table

#>

