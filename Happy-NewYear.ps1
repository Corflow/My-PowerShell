#this must be run in the PowerShell console NOT the ISE
if ($host.name -ne ‘ConsoleHost’) {
Write-Warning “Sorry. This must be run in the PowerShell console.”
#bail out
Return
}

#get window dimensions
$X = $host.ui.RawUI.WindowSize.width
#subtract 5 to accomodate the end of the script
$Y = $host.ui.RawUI.WindowSize.Height – 5

#save current window title
$title = $host.ui.RawUI.WindowTitle

#get an array of console colors
$colors = [enum]::GetNames([consolecolor])

#
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.SelectVoice(‘Microsoft Zira Desktop’)

#clear the screen
cls
#for every line of window height counting down
$Y..1 | Foreach {
#write a randomized colored row
1..$X | foreach {
Write-Host ” ” -BackgroundColor (Get-Random $colors) -NoNewline
}
#count down the last 10
if ($_ -le 10) {
$host.ui.RawUI.WindowTitle = $_
$speak.Speak($_)
#[console]::Beep()
#Start-Sleep -Milliseconds 500
}
}
$speak.Speak(‘Happy New Year!’)
$msg = “Happy New Year!”

$msg.ToCharArray() | foreach -Begin {Write-Host “n"} -process {
Write-Host $_ -NoNewline -ForegroundColor (Get-Random $colors) -BackgroundColor (Get-Random $colors)
} -end { Write-Host "n” }

#reset the window Title
$host.ui.RawUI.WindowTitle = $Title