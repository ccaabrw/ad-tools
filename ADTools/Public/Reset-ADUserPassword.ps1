<#
.SYNOPSIS
    Resets the password for an Active Directory user account.

.PARAMETER Identity
    The SamAccountName, UPN, or DistinguishedName of the user.

.PARAMETER NewPassword
    The new password as a SecureString.

.PARAMETER MustChangePasswordAtLogon
    If specified, forces the user to change their password on next logon.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    $pwd = Read-Host "New password" -AsSecureString
    Reset-ADUserPassword -Identity jdoe -NewPassword $pwd

.EXAMPLE
    $pwd = Read-Host "New password" -AsSecureString
    Reset-ADUserPassword -Identity jdoe -NewPassword $pwd -MustChangePasswordAtLogon
#>
function Reset-ADUserPassword {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Identity,

        [Parameter(Mandatory)]
        [System.Security.SecureString]$NewPassword,

        [Parameter()]
        [switch]$MustChangePasswordAtLogon,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin {
        $adParams = @{}
        if ($Credential) { $adParams.Credential = $Credential }
    }

    process {
        try {
            $user = Get-ADUser -Identity $Identity @adParams -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve user '$Identity': $_"
            return
        }

        if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Reset password")) {
            try {
                Set-ADAccountPassword -Identity $user -NewPassword $NewPassword -Reset @adParams -ErrorAction Stop

                if ($MustChangePasswordAtLogon) {
                    Set-ADUser -Identity $user -ChangePasswordAtLogon $true @adParams -ErrorAction Stop
                }

                Write-Verbose "Password reset for '$($user.SamAccountName)'."
            }
            catch {
                Write-Error "Failed to reset password for '$($user.SamAccountName)': $_"
            }
        }
    }
}
