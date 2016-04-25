
function Get-PerfCounters
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
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin
    {
    }
    Process
    {
    }
    End
    {
    }
}

function Perf-Progress
{
<#
 -----------------------------------------------------------------------------
 Script: demo-wmiperf-progress.ps1
 Version: 1.0
 Author: Jeffery Hicks
    http://jdhitsolutions.com/blog
    http://twitter.com/JeffHicks
    http://www.ScriptingGeek.com
 Date: 10/26/2011
 Keywords:
 Comments: This is a more developed version of the demonstration
 script used in the Windows Server 2008 PowerShell Training course.
 
 "Those who forget to script are doomed to repeat their work."

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
 -----------------------------------------------------------------------------
 #>
 
    [cmdletbinding()]

        Param(
        [Parameter(Position=0)]
        [ValidateNotNullorEmpty()]
        [string]$Class="Win32_PerfFormattedData_PerfDisk_LogicalDisk",
        [Parameter(Position=1)]
        [ValidateNotNullorEmpty()]
        [string]$Filter="Name='C:'",
        [Parameter(Position=2)]
        [ValidateNotNullorEmpty()]
        [string]$Property="PercentDiskTime",
        [string]$Computername=$env:computername,
        [int]$Sleep=1,
        [int]$Maximum=60,
        [string]$Log
        )

    Write-Verbose ("Querying {0} filter {1} on {2} every {3} second(s) {4} times." -f $class,$filter,$computername,$sleep,$maximum)

    #values for Write-Progress
    $activity=$class
    $status="$Property -> $Filter"
    $current=$computername.ToUpper()

    Write-Verbose "Graphing the $Property property"

    #define an array to hold the results
    $results=@()
            for ($i=1; $i -le $maximum; $i++) 
            {
              Try 
              {
                $stat=get-wmiobject -class $activity -filter $filter -computername $computername -ErrorAction Stop
                $results+=$stat
                Write-progress -Activity $activity -status $status -currentoperation $current -PercentComplete $stat.$Property
                sleep -seconds $sleep
              }
              Catch 
              {
                Write-Warning $_.Exception.Message
                Return
              }
            }

            if ($Log) 
            {
                #export results to a file
                Write-Verbose "Exporting results to $log"
                $results | export-csv -Path $log
            }

Write-Progress -Activity $activity -status "Finished" -Completed
Write-Verbose "Finished"
}

<#

## Example of getting Processor Performance Data. ##
cls

$c="Win32_PerfFormattedData_PerfOS_Processor"

Get-WmiObject $c -Filter "Name='_Total'"

#-----------------------------------------------------------#

# Define Variables #
$comp=$POD0
$computer=@{Name="Computer Name";Expression={$_.__SERVER}}

gwmi Win32_PerfFormattedData_PerfOS_Memory -ComputerName $comp `
| select AvailableMBytes,@{Name="Committed Mb";Expression={$_.CommittedBytes/1MB}},
@{Name="Pool Paged Mb";Expression={$_.PoolPagedBytes/1MB}},
@{Name="Pool Non-Paged Mb";Expression={$_.PoolNonPagedBytes/1MB}},
$computer | Format-Table -AutoSize

#-----------------------------------------------------------#

# Define Variables#
$computer=@{Name="Computer Name";Expression={$_.__SERVER}}
$class="Win32_PerfFormattedData_PerfDisk_LogicalDisk"

# Create a job to gather performance counters. #
icm {dir C:\ -Recurse} -computername "localhost" -AsJob

# Watch C: Drive usage. #
    for ($i=1;$i -le 5;$i++)
    {
    gwmi $class -Filter "Name='c:'" -ComputerName localhost `
    | select $computer, Name, CurrentDiskQueueLength, PercentDisk*,
    @{Name="Time";Expression={(Get-Date).TimeOfDay}}
    sleep 5
    }

#>

## Example of capturing disk performance data. ##

#To list all the possible commands with counters type
#Help Counter

<#

$DiskCounters=@(
"\LogicalDisk(c:)\Avg. Disk Bytes/Transfer",
"\LogicalDisk(c:)\Avg. Disk Queue Length",
"\LogicalDisk(c:)\Avg. Disk sec/Transfer"
"\LogicalDisk(c:)\Current Disk Queue Length"
)

$computer='BNA-PR-MID01'

$DiskCounters | Get-Counter -ComputerName $computer

#--------------------------------------------------------#

# Query computers free disk space (example here is less than 90%).
$computer=$POD0
Get-Counter "LogicalDisk(c:)\% Free Space" -ComputerName $computer `
| select -ExpandProperty CounterSamples `
| select Path, CookedValue | where {$_.CookedValue -le 90}

#----------------------------------------------------------#

# Writing couters to a file. #
$DiskCounters=@(
"\LogicalDisk(c:)\Avg. Disk Bytes/Transfer",
"\LogicalDisk(c:)\Avg. Disk Queue Length",
"\LogicalDisk(c:)\Avg. Disk sec/Transfer"
"\LogicalDisk(c:)\Current Disk Queue Length"
)

$DiskCounters | Get-Counter -ComputerName $computer -MaxSamples 60 `
-SampleInterval 30 | Export-Counter -FileFormat CSV -Path `
"C:\Logs\DiskCounters.csv" -Force

#--------------------------------------------------------#


$DiskCounters=@(
"\LogicalDisk(c:)\Avg. Disk Bytes/Transfer",
"\LogicalDisk(c:)\Avg. Disk Queue Length",
"\LogicalDisk(c:)\Avg. Disk sec/Transfer"
"\LogicalDisk(c:)\Current Disk Queue Length"
)

$computer=$POD0

$DiskCounters | Get-Counter -ComputerName $computer `
| select -ExpandProperty Countersamples `
| Format-List

Get-Counter -Counter $DiskCounters -ComputerName $computer

#----------------------------------------------------------#

## Create variables. ##
$log="C:\Logs\DiskCounters.csv"
$computer=$env:COMPUTERNAME


## Start Job to get disk counters. ##
Start-Job{
$args[0] | Get-Counter -ComputerName $args[1] -MaxSamples 32 -SampleInterval 15 `
| Export-Counter -FileFormat CSV -Path $args[2] -Force
} -name DiskPerf -arg $DiskCounters,$computer,$log

## Create some load on the system to get some disk I/O. ##

Invoke-Command {Start-Job {dir c:\ -Recurse}} -computername $computer

## Wait for the DiskPerf job to finish. ##
Wait-Job DiskPerf

#---------------------------------------------------------------#

# Use PowerShell to import the counter data. #

$DiskCounter="C:\Logs\DiskCounters.csv"
Import-counter $DiskCounter $log -Summary

## Create a variable to import the counter data. ##
$data=Import-counter $log

## Different ways to view the counter data. ##
$data.count
$data[0]
$data[2]

## just one servers counter samples. ##
$data | select -ExpandProperty CounterSamples `
| where {$_.path -match "WEB03"}

## Find one specific counter on a specific server. ##
$ctr="\\BNA-PR-GW-WEB02\\LogicalDisk(c:)\Avg. Disk Sec/Transfer"

$data | select -ExpandProperty CounterSamples `
| where {$_.path -eq $ctr} `
| select TimeStamp, CookedValue, Path `
| Format-Table

## Get the overall average for the counters. ##
$DiskCounter1 = Import-Counter "C:\Logs\DiskCounters1.csv"

$DiskCounter1 | select -ExpandProperty CounterSamples | group Path `
| select Name,
@{Name="Overall Average";Expression={($_.Group | meaure CookedValue -average).average}} | ft -AutoSize

#----------------------------------------------------------#

#>