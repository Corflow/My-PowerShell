#
#.SYNOPSIS
#Sends SMTP email via the SMTP Relay
#
#.EXAMPLE
#.\Send-Email.ps1 -To "administrator@PremiseHealth.com" -Subject "Test email" -Body "This is a test"
#

param(
[string]$to,
[string]$subject,
[string]$body
)

$smtpServer = "relay.premisehealth.com"
$smtpFrom = "Reports@PremiseHealth.com"
$smtpTo = $to
$messageSubject = $subject
$messageBody = $body

$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($smtpFrom,$smtpTo,$messagesubject,$messagebody)