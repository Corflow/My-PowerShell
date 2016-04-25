
$servers = $PrimeSuite_All

ForEach ($server in $servers) 
{
Invoke-Command -ComputerName $server {Get-ChildItem "D:\*\*\*\*connectioninfo*.xml" -Recurse | select @{N="Computer Name";E={$env:COMPUTERNAME}}, Name, 
@{N="Last Write Time";E={$_.LastWriteTime}}, 
@{N="Full Path";E={$_.Directory}}} | Export-Csv -Path C:\ConnectionInfo_D.csv -Append
}


<#
$servers = $PrimeSuite_All

ForEach ($server in $servers) 
{
Invoke-Command -ComputerName $server {Remove-Item "C:\ConnectionInfo2.csv" -Force -Verbose}  
}
#> 