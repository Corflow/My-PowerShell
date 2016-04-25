Function Get-LocalGroupMembers  {

      [Cmdletbinding()] 

          Param
          ( 

          [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] 

          [String[]]$Computername =  $Env:COMPUTERNAME,

          [parameter()]

          [string[]]$Group

          )

    Begin 
    {
        Function  ConvertTo-SID 
                    {

                    Param([byte[]]$BinarySID)

                    (New-Object  System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value

                    }

        Function  Get-LocalGroupMember 
                    {

              Param  ($Group)

                      $group.Invoke('members')  | ForEach {

                      $_.GetType().InvokeMember("Name",  'GetProperty',  $null,  $_, $null)

                      }

                    }# End Get-LocalGroupMember Function

              }# End Begin Block

    Process  
    {

        ForEach  ($Computer in  $Computername) 
        {

            Try  
            {

                  Write-Verbose  "Connecting to $($Computer)"

                  $adsi  = [ADSI]"WinNT://$Computer"

                    If  ($PSBoundParameters.ContainsKey('Group')) 
                      {

                      Write-Verbose  "Scanning for groups: $($Group -join ',')"

                      $Groups  = ForEach  ($item in  $group) {                        

                      $adsi.Children.Find($Item, 'Group')

                        }# End Foreach Block

                      }# End IF Block
                 
                    Else  
                      {

                      Write-Verbose  "Scanning all groups"

                      $groups  = $adsi.Children | where {$_.SchemaClassName -eq  'group'}

                      }# End Else Block

                     If  ($groups) 
                     {

                        $groups  | ForEach {

                              [pscustomobject]@{

                              Computername = $Computer

                              Name = $_.Name[0]

                              Members = ((Get-LocalGroupMember  -Group $_))  -join ', '

                              SID = (ConvertTo-SID -BinarySID $_.ObjectSID[0])

                            }# End PS Custom Object Block

                        }# End Foreach Block

                    }# End If Block
                  
                    Else  
                    {

                    Throw  "No groups found!"

                    }# End Else Block

                }# End Try Block
              
            Catch  
            {

              Write-Warning  "$($Computer): $_"

            }# End Catch Block

        }# End Foreach Block

    }# End Process Block

}


Get-LocalGroupMembers