<#
.SYNOPSIS
    Lists members of an Active Directory group.

.PARAMETER Identity
    The SamAccountName or DistinguishedName of the group.

.PARAMETER Recursive
    If specified, expands nested groups and returns all transitive members.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Get-ADGroupMembers -Identity "VPN-Users"

.EXAMPLE
    Get-ADGroupMembers -Identity "Domain Admins" -Recursive
#>
function Get-ADGroupMembers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Identity,

        [Parameter()]
        [switch]$Recursive,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin {
        $adParams = @{}
        if ($Credential) { $adParams.Credential = $Credential }
    }

    process {
        try {
            $group = Get-ADGroup -Identity $Identity @adParams -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve group '$Identity': $_"
            return
        }

        $memberParams = @{ Identity = $group }
        if ($Recursive) { $memberParams.Recursive = $true }

        try {
            Get-ADGroupMember @memberParams @adParams -ErrorAction Stop | ForEach-Object {
                [PSCustomObject]@{
                    SamAccountName = $_.SamAccountName
                    Name           = $_.Name
                    ObjectClass    = $_.objectClass
                    DistinguishedName = $_.DistinguishedName
                }
            }
        }
        catch {
            Write-Error "Failed to retrieve members of '$($group.Name)': $_"
        }
    }
}
