<#
.SYNOPSIS
    Disables an Active Directory user account.

.PARAMETER Identity
    The SamAccountName, UPN, or DistinguishedName of the user to disable.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Disable-ADUserAccount -Identity jdoe

.EXAMPLE
    "jdoe","jsmith" | Disable-ADUserAccount
#>
function Disable-ADUserAccount {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Identity,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin {
        $adParams = @{}
        if ($Credential) { $adParams.Credential = $Credential }
    }

    process {
        try {
            $user = Get-ADUser -Identity $Identity -Properties Enabled @adParams -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve user '$Identity': $_"
            return
        }

        if (-not $user.Enabled) {
            Write-Verbose "'$($user.SamAccountName)' is already disabled. No action taken."
            return
        }

        if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Disable account")) {
            try {
                Disable-ADAccount -Identity $user @adParams -ErrorAction Stop
                Write-Verbose "Disabled '$($user.SamAccountName)'."
            }
            catch {
                Write-Error "Failed to disable '$($user.SamAccountName)': $_"
            }
        }
    }
}
