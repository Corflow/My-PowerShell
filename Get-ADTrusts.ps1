
Import-module ActiveDirectory
$DomainDNS = (Get-ADDomain).DNSRoot

Write-output "Get list of AD Domain Trusts in $DomainDNS `r"
$ADDomainTrusts = Get-ADObject -Filter {ObjectClass -eq "trustedDomain"} -Properties *
[int]$ADDomainTrustsCount = $ADDomainTrusts.Count

Write-Output "Discovered $ADDomainTrustsCount trusts in $DomainDNS"

IF ($ADDomainTrustsCount -ge 1)
    {  ## OPEN IF ($ADDomainTrustsCount -ge 1)
        ForEach ($Trust in $ADDomainTrusts)
        {  ## OPEN ForEach ($Trust in $ADDomainTrusts)
            $TrustName = $Trust.Name
            $TrustDescription = $Trust.Description
            $TrustCreated = $Trust.Created
            $TrustModified = $Trust.Modified
            $TrustDirectionNumber = $Trust.trustDirection
            $TrustTypeNumber = $Trust.trustType
            $TrustAttributesNumber = $Trust.trustAttributes
            

            SWITCH ($TrustTypeNumber)
                {  ## OPEN SWITCH ($TrustTypeNumber)
                    1 { $TrustType = "Downlevel (Windows NT domain external"}
                    2 { $TrustType = "Uplevel (Active Directory domain - parent-child, root domain, shortcut, external, or forest"}
                    3 { $TrustType = "MIT (non-Windows) Kerberos version 5 realm"}
                    4 { $TrustType = "DCE (Theoretical trust type - DCE refers to Open Group's Distributed Computing Environment specification."}
                }  ## CLOSE SWITCH ($TrustTypeNumber)

            IF (!$TrustType) { $TrustType = $TrustTypeNumber }
            
            SWITCH ($TrustAttributesNumber)
                {  ## OPEN SWITCH ($TrustTypeNumber)
                    1 { $TrustAttributes = "Non-Transitive"}
                    2 { $TrustAttributes = "Uplevel clients only (Windows 2000 or newer"}
                    4 { $TrustAttributes = "Quarantined Domain (External)"}
                    8 { $TrustAttributes = "Forest Trust"}
                    10 { $TrustAttributes = "Cross-Organizational Trust (Selective Authentication)"}
                    20 { $TrustAttributes = "Intra-Forest Trust (trust within the forest)"}
                }  ## CLOSE SWITCH ($TrustTypeNumber)
            
             IF (!$TrustAttributes) { $TrustAttributes = $TrustAttributesNumber }
            
            SWITCH ($TrustDirectionNumber)
                {  ## OPEN SWITCH ($TrustTypeNumber)
                    1 { $TrustDirection = "Inbound (TrustING domain)"}
                    2 { $TrustDirection = "Outbound (TrustED domain)"}
                    3 { $TrustDirection = "Bidirectional (two-way trust)"}
                }  ## CLOSE SWITCH ($TrustTypeNumber)
            
             IF (!$TrustDirection) { $TrustDirection = $TrustDirectionNumber }
                  
             Write-output "Trust Name: $TrustName `r "
             Write-output "Trust Description: $TrustDescription `r "
             Write-output "Trust Created: $TrustCreated `r "
             Write-output "Trust Modified: $TrustModified  `r "
             Write-output "Trust Direction: $TrustDirection `r "
             Write-output "Trust Type: $TrustType `r "
             Write-output "Trust Attributes: $TrustAttributes `r "
             Write-output " `r "
            
        }  ## CLOSE ForEach ($Trust in $ADDomainTrusts)
    }  ## CLOSE IF ($ADDomainTrustsCount -ge 1)