<#
.SYNOPSIS
    Enables an Active Directory user account.

.PARAMETER Identity
    The SamAccountName, UPN, or DistinguishedName of the user to enable.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Enable-ADUserAccount.ps1 -Identity jdoe

.EXAMPLE
    "jdoe","jsmith" | Enable-ADUserAccount.ps1
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
        $user = Get-ADUser -Identity $Identity -Properties Enabled @adParams -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to retrieve user '$Identity': $_"
        return
    }

    if ($user.Enabled) {
        Write-Verbose "'$($user.SamAccountName)' is already enabled. No action taken."
        return
    }

    if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Enable account")) {
        try {
            Enable-ADAccount -Identity $user @adParams -ErrorAction Stop
            Write-Verbose "Enabled '$($user.SamAccountName)'."
        }
        catch {
            Write-Error "Failed to enable '$($user.SamAccountName)': $_"
        }
    }
}
