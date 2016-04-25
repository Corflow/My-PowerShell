function Get-Bethoven
{
<#
1 = QUARTER NOTE
1.25 = QUARTER AND HALF
.5 = EIGHTH NOTE
.25 = SIXTEENTH NOTE
2 = HALF NOTE
#>

#<duration><note>[<octave>]

$notes = @"
1B 1B 1C 1D2 1D2 1C 1B 1A 1G 1G 1A 1B 1.5B .5A 2A
1B 1B 1C 1D2 1D2 1C 1B 1A 1G 1G 1A 1B 1.5A .5G 2G
2A 1B 1G 1A .5B .5C 1B 1G 1A .5B .5C 1B 1A 1G 1A 2D
1B 1B 1C 1D2 1D2 1C 1B 1A 1G 1G 1A 1B 1.5A .5G 2G
"@


$scale=@{
MidC=262
CSharp=277
D=294
DSharp=311
E=330
F=350
FSharp=370
G=392
GSharp=415
A=440
ASharp=466
B=494
C=523
}

#define a quarter note duration in milliseconds
$Q = 425

#define a regex to parse notations using named captures
[regex]$rx = "(?<duration>(\.)?\d+(\.\d+)?)(?<note>\w)(?<octave>\d)?"

#this code doesn't take into account situations where you need to
#go down an octave
        $rx.matches($notes) | foreach {
         $freq = $scale.item($_.groups["note"].value)
                 if ($_.groups["octave"].value) 
                 {
                   [int]$octave = $_.groups["octave"].value
                 }
                 
                 else 
                 {
                    $octave = 1
                 }

                 $duration = ($_.groups["duration"].value -as [double]) * $Q
                 [console]::beep($freq*$octave,$duration) 
                }

}