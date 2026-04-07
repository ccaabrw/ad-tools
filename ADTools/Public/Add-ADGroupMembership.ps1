<#
.SYNOPSIS
    Adds a user to an Active Directory group.

.PARAMETER UserIdentity
    The SamAccountName, UPN, or DistinguishedName of the user to add.

.PARAMETER GroupIdentity
    The SamAccountName or DistinguishedName of the target group.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Add-ADGroupMembership -UserIdentity jdoe -GroupIdentity "IT-Helpdesk"

.EXAMPLE
    "jdoe","jsmith" | Add-ADGroupMembership -GroupIdentity "VPN-Users"
#>
function Add-ADGroupMembership {
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

        if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Add to group '$($group.Name)'")) {
            try {
                Add-ADGroupMember -Identity $group -Members $user @adParams -ErrorAction Stop
                Write-Verbose "Added '$($user.SamAccountName)' to '$($group.Name)'."
            }
            catch {
                Write-Error "Failed to add '$($user.SamAccountName)' to '$($group.Name)': $_"
            }
        }
    }
}
