#PSVersiontable trick
<#
$PSVersionTable.Add("OS",(Get-WmiObject Win32_Operatingsystem).caption)

$PSVersionTable
#>


#PSSession tricks
<#
$Computer = "BNA-PR-GW-WEB09"

$s = New-PSSession -ComputerName $Computer

Get-PSSession

Enter-PSSession -Session $s

get-windowsfeature web*

Get-Module web* -ListAvailable

Import-Module web*

cd iis:

dir

dir sites

#>


#Invoke-Command tricks
<#
$Computer = "BNA-PR-GW-WEB09"

$s = New-PSSession -ComputerName $Computer

icm { $p = Get-Process | sort -Descending } -Session $s

icm {$p[0..4] } -session $s
#>


#One to many examples - "Fanning Out" with Invoke-Command
<#
$QAPS = New-PSSession -ComputerName Q-AP-PS-01,Q-DB-PS-01 -Credential PremiseHealth\Steve.Ross

#Invoke-Command -ScriptBlock { Get-Service *PaperSave* } -Session $QAPS

#Invoke-Command -ScriptBlock { Get-WindowsFeature | Where installed | Format-Table -AutoSize } -Session $QAPS

#Script resides locally, executed remotely
# Invoke-Command -FilePath c:\scripts\weekly.ps1 -Session $QAPS

#Check the timezone on each
#icm { tzutil /g } -session $QAPS
#>


#One to many examples - "Fanning Out" with New-PSSessions and Jobs
<#
New-PSSession -ComputerName Q-AP-PS-01,Q-DB-PS-01 -Credential PremiseHealth\Steve.Ross
$all = Get-PSSession
$all.count

#tee displays the job to the console and -Variable hot creates the variable hot
icm { Get-HotFix } -session $all -AsJob | tee -Variable hot
$hot

#Get jobs associated with all sessions
$hot.childJobs

#This will wait until the jobs finish before it displays the prompt at the console again
#Wait-Job $hot

#using the Keep switch will not remove the results from the job queue, if the job runs for a long time you dont want to re-run it.
$data = Receive-Job $hot -Keep

#count the number of hotfixes on the servers
$data.count

$data | select -First 3

$data | group PSComputername

#One to many examples - "Fanning Out" with New-PSSessions and using Script Blocks for Jobs

$sb = { Start-Job { Get-EventLog system -EntryType error } -Name SysErr }

#Creates a job on each of the remote systems for the command in the $sb variable
icm $sb -session $all

#script to loop through while all the jobs are running
do { Start-Sleep -Milliseconds 10 } while ( icm { Get-Job -State Running } -session $all )

#get the results from the first session in $all
icm { Get-Job SysErr } -session $all[0]

#get the results from the every session in $all
icm { Get-Job SysErr } -session $all

#retrieve the results from all the servers
$syserrs = icm { Receive-Job SysErr -Keep } -session $all
$syserrs.count

$syserrs[0] | select *

$syserrs | group source -NoElement | sort count -Descending | select -First 10

#measure the command letting the local system process the data
Measure-Command { icm { get-windowsfeature } -session $all | where installed | select *Name }

#measure the command letting the remote systems process the data
Measure-Command { icm { get-windowsfeature | where installed | select *Name } -session $all }
#>