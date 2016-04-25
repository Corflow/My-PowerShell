
[string]$Subnet,
[int]$StartIP,
[int]$EndIP

<#
$StartIP..$EndIP | foreach {
Test-Connection "$Subnet$_" -Count 1
}
#>

$StartIP..$EndIP | where {
Test-Connection "$Subnet$_" -Count 1
} | foreach { "$Subnet$_" }
