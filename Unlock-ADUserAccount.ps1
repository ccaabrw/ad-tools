<#
.SYNOPSIS
    Unlocks a locked Active Directory user account.

.PARAMETER Identity
    The SamAccountName, UPN, or DistinguishedName of the user to unlock.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Unlock-ADUserAccount.ps1 -Identity jdoe

.EXAMPLE
    "jdoe","jsmith" | Unlock-ADUserAccount.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]$Identity,

    [Parameter()]
    [System.Management.Automation.PSCredential]$Credential
)

begin {
    Import-Module ActiveDirectory -ErrorAction Stop

    $adParams = @{}
    if ($Credential) { $adParams.Credential = $Credential }
}

process {
    try {
        $user = Get-ADUser -Identity $Identity -Properties LockedOut @adParams -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to retrieve user '$Identity': $_"
        return
    }

    if (-not $user.LockedOut) {
        Write-Verbose "'$($user.SamAccountName)' is not locked out. No action taken."
        return
    }

    if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Unlock account")) {
        try {
            Unlock-ADAccount -Identity $user @adParams -ErrorAction Stop
            Write-Verbose "Unlocked '$($user.SamAccountName)'."
        }
        catch {
            Write-Error "Failed to unlock '$($user.SamAccountName)': $_"
        }
    }
}
