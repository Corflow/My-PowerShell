#This is a script that you would schdeule to run every 5 minutes to test the connectivity of one or more systems.

#Email Alert Parameters
 
$to = "Steve.Ross@PremiseHealth.com"
 
$from = "Reports@PremiseHealth.com"
 
$smtpserver = "Relay.PremiseHealth.com"
 
########################################################################
 
#Array of computers to test
 
$Computers = (Get-Content D:\AppEng\Servers\Greenway_VPN_By_Name.txt)

########################################################################
 
#Variable to hold INT value 0
$zero = 0

########################################################################
 
foreach ($Computer in $Computers)
 
    {
 
        if
        (
        #Checks for a file with the host computers name in the Reports folder and if it doesn't exist creates it with content 0.
        Test-Path $("D:\AppEng\Reports\" + $Computer + ".txt")
        )
 
        {
 
        }
 
        else
 
        {
 
        $zero > $("D:\AppEng\Reports\" + $Computer + ".txt")
 
        }

        #Reads the content of the file and saves to variable as text.
        $FailedPings = Get-Content $("D:\AppEng\Reports\" + $Computer + ".txt")

        #Converts the value to INT.
        $INT_FailedPings  = [INT]$FailedPings
        
        #Actual PING test.
        $PingTest = Test-Connection -ComputerName $Computer -count 1
 
            if 
                (
                
                #If ping is unsuccessful.
                $PingTest.StatusCode -ne "0"
 
                )
 
                {
 
                if
                (

                #If previous failed pings value is less or equal to 3.
                $INT_FailedPings  -le 3
 
                )
 
                        {
        
                        #Increment the value by 1.
                        $INT_FailedPings++
        
                        #Write the value out to the reports folder file for this host.
                        $INT_FailedPings  > $("D:\AppEng\Reports\"  + $Computer  + ".txt")
        
                        #Send an alert of failed ping.
                        Send-MailMessage -to $to -subject "Warning, $Computer is down!" -from $from  -body "PING to $Computer across Greenway's VPN tunnel has failed!" -smtpserver $smtpserver
 
                        }
 
                }
 
                elseif
 
                (
                
                #If previous checks have failed the value will be non zero, as checks are now working sets the value back to zero and alerts that host is back up.
                $INT_FailedPings  -ne 0
 
                )
 
                {
 
                        $zero > $("D:\AppEng\Reports\" + $Computer + ".txt")
 
                        Send-MailMessage -to $to -subject "$Computer is back up" -from $from  -body "We are able to PING $computer across Greenway's VPN tunnel again."  -smtpserver $smtpserver
 
                }
 
                        else
                        #If ping is successful and past pings were successful do nothing.
                {
 
                }
 
    }