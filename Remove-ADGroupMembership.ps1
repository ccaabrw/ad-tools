<#
.SYNOPSIS
    Removes a user from an Active Directory group.

.PARAMETER UserIdentity
    The SamAccountName, UPN, or DistinguishedName of the user to remove.

.PARAMETER GroupIdentity
    The SamAccountName or DistinguishedName of the target group.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Remove-ADGroupMembership.ps1 -UserIdentity jdoe -GroupIdentity "IT-Helpdesk"

.EXAMPLE
    "jdoe","jsmith" | Remove-ADGroupMembership.ps1 -GroupIdentity "VPN-Users"
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]$UserIdentity,

    [Parameter(Mandatory)]
    [string]$GroupIdentity,

    [Parameter()]
    [System.Management.Automation.PSCredential]$Credential
)

begin {
    Import-Module ActiveDirectory -ErrorAction Stop

    $adParams = @{}
    if ($Credential) { $adParams.Credential = $Credential }

    try {
        $group = Get-ADGroup -Identity $GroupIdentity @adParams -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve group '$GroupIdentity': $_"
    }
}

process {
    try {
        $user = Get-ADUser -Identity $UserIdentity @adParams -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to retrieve user '$UserIdentity': $_"
        return
    }

    if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Remove from group '$($group.Name)'")) {
        try {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false @adParams -ErrorAction Stop
            Write-Verbose "Removed '$($user.SamAccountName)' from '$($group.Name)'."
        }
        catch {
            Write-Error "Failed to remove '$($user.SamAccountName)' from '$($group.Name)': $_"
        }
    }
}
