<#
.SYNOPSIS
    Returns status information for an Active Directory user account.

.DESCRIPTION
    Queries AD for a user and returns enabled state, lockout status, last logon,
    password information, and group memberships.

.PARAMETER Identity
    The SamAccountName, UPN, or DistinguishedName of the user.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Get-ADUserStatus.ps1 -Identity jdoe

.EXAMPLE
    Get-ADUserStatus.ps1 -Identity jdoe | Select-Object Name, Enabled, LockedOut
#>
[CmdletBinding()]
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
    $properties = @(
        'Enabled',
        'LockedOut',
        'LastLogonDate',
        'PasswordLastSet',
        'PasswordExpired',
        'PasswordNeverExpires',
        'AccountExpirationDate',
        'MemberOf',
        'DisplayName',
        'EmailAddress',
        'Title',
        'Department'
    )

    try {
        $user = Get-ADUser -Identity $Identity -Properties $properties @adParams -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to retrieve user '$Identity': $_"
        return
    }

    $groups = $user.MemberOf | ForEach-Object {
        (Get-ADGroup -Identity $_ @adParams).Name
    } | Sort-Object

    [PSCustomObject]@{
        SamAccountName       = $user.SamAccountName
        DisplayName          = $user.DisplayName
        EmailAddress         = $user.EmailAddress
        Title                = $user.Title
        Department           = $user.Department
        Enabled              = $user.Enabled
        LockedOut            = $user.LockedOut
        LastLogonDate        = $user.LastLogonDate
        PasswordLastSet      = $user.PasswordLastSet
        PasswordExpired      = $user.PasswordExpired
        PasswordNeverExpires = $user.PasswordNeverExpires
        AccountExpirationDate = $user.AccountExpirationDate
        Groups               = $groups
    }
}
