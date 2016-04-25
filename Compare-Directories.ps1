$a = Get-childitem -Recurse -Path c:\inetpub\wwwroot\EligibilityAdminTest\
$b = Get-childitem -Recurse -Path D:\Backup\EligibilityAdmin_2015-12-31T14.49.54\
Compare-object -ReferenceObject $a -DifferenceObject $b | Measure-Object | select -ExpandProperty count