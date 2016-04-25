# Check WmiObject Classes
Clear-Host
$Type = "Disk" 
Get-WmiObject -List | Where-Object {$_.name -Match $Type}

# 1 way to display Logical Disk information
Clear-Host
Get-WmiObject Win32_logicaldisk | Format-Table -auto

# Another way to display Logical Disk information
Clear-Host
Get-WmiObject -query "Select * from Win32_logicaldisk" |Ft

# Properties for PowerShell logical disk object: 
Get-WmiObject Win32_logicaldisk | Get-Member

# PowerShell command disk space 
Get-WmiObject Win32_logicaldisk `
| Format-Table DeviceId, MediaType, Size, FreeSpace -auto

Clear-Host
Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
@{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}}, `
@{Name="Free Space(GB)";Expression={[decimal]("{0:N0}" -f($_.freespace/1gb))}}, `
@{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}} `
-AutoSize

# PowerShell cmdlet to display a disk's partition information.
Clear-Host
$Item = @("Name","DiskIndex", "StartingOffset", "Bootable", "BlockSize", "NumberOfBlocks")
Get-WmiObject -query "Select * from Win32_DiskPartition" | Format-Table $item -auto

# Properties for PowerShell disk partition object: 
Get-WmiObject Win32_DiskPartition | Get-member.