function Speak-Text
{
<#
.Synopsis
Speaks text from a .txt file referenced with the -TextPath switch.
.DESCRIPTION
Speaks text from a .txt file referenced with the -TextPath switch, this works on one or multiple systems.
.EXAMPLE
Speak-Text -ComputerName localhost -TextPath C:\Voice\Phrases.txt
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Computer or Computers to query
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$TextPath

    )

    Begin
    {
    }
    Process
    {
        foreach($computer in $ComputerName)
        {
        [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null 
        #Invoke-WebRequest -uri "http://mattblogsit.com/prankphrases.txt" -OutFile $HOME\bin\prankphrases.txt
        #$phrases = Get-Content $HOME\bin\prankphrases.txt
        $phrases =  Get-Content $TextPath
        #$phrase = Get-Random $phrases
        $object = New-Object System.Speech.Synthesis.SpeechSynthesizer 
        $object.Voice.Gender.Male
        $object.Speak($phrases)
        }
    }
    End
    {
    }
}