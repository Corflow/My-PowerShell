Function Sweep-Subnet($Subnet) #in the format of "10.10.10."
{
<#
1. The subnet passed to the function is incremented by 1 up until 254 building an array of each possible IP address ($arrIPs)
2. This array is iterated through, each pass the IP address is pinged.
3. If the ping is successful (StatusCode of “0”)  a WMI connection is attempted
4. A successful WMI connection indicates that this is a valid Windows machine (NOTE: In order to connect via WMI, appropriate permissions are required)
and the machine’s name is added to the array ($arrValid)
5. The array has any duplicate names removed and is returned to the script calling the function.

Some types of scripts I’ve personally used this function for include:
1. A server inventory script where I need to confirm each server on a given subnet and then gather pull information from each server (hardware specs, software, serial number, etc).
2. Mass shutdown script where an entire subnet needs to be shutdown as quickly as possible. This function ensures that all Windows servers or PCs are passed to the shutdown script.
3. Server reconfiguration changes. If a large subset of servers needs a specific configuration change, this function will give you all valid computers on a given subnet and from that
list you can poll for whatever criteria. A good example I recently used was a recent change to the descriptions for all servers SNMP service settings. I used this function to feed a 
list of all servers a script which then read the current configuration of the server, determined if it was a physical or VM and updated the descriptions accordingly. Saved me several 
hour of manual, tedious, error-prone work.

To call this function simply insert the code in the beginning of your script. 
Wherever you need the array of valid computers type:
$examplearray = Sweep-Subnet -Subnet "192.168.1."
#>
      $arrIPs = @();$arrValid = @() #Creates 2 arrays, one to hold the IP addresses and the other to hold confirmed Windows machines
      For($x=1; $x -lt 254; $x++) #Starting at 1 and incrementing to 254, each time building a new IP address based on the subnet
         {
            $IPAddress = $Subnet + $x;$arrIPs += $IPAddress
         }
      ForEach ($IP in $arrIPs)
         {
            $ping = Get-WMIObject -Class Win32_PingStatus -Filter "Address='$IP'" #Ping each IP address
            If ($ping.StatusCode -eq "0")
               {
                  #Attempt to connect to each online machine using WMI, this confirms whethers it's a Windows machine
                  $checkOS = Get-WMIObject -Class Win32_OperatingSystem -ComputerName "$IP" -ErrorAction SilentlyContinue
                  #Add this computer name to the valid array
                  If ($checkOS -ne $null) {$arrValid += @($checkOS.CSName)}
               }
         }
       #Remove any duplicate entries, this accounts for any multihomed machines
       $arrValid = $arrValid | Select-Object -Unique
       #Return the valid array to any script you choose to call this function from
       return $arrValid
}