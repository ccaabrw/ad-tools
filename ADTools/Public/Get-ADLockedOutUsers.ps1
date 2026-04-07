<#
.SYNOPSIS
    Returns all locked-out Active Directory user accounts.

.PARAMETER SearchBase
    Optional OU DistinguishedName to scope the search (e.g. "OU=Users,DC=contoso,DC=com").
    Defaults to the entire domain.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Get-ADLockedOutUsers

.EXAMPLE
    Get-ADLockedOutUsers -SearchBase "OU=Employees,DC=contoso,DC=com"
#>
function Get-ADLockedOutUsers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SearchBase,

        [Parameter()]
        [System.Management.Automation.PSCredential]$Credential
    )

    $adParams = @{}
    if ($Credential) { $adParams.Credential = $Credential }
    if ($SearchBase) { $adParams.SearchBase = $SearchBase }

    try {
        Search-ADAccount -LockedOut -UsersOnly @adParams -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                SamAccountName    = $_.SamAccountName
                Name              = $_.Name
                LockedOut         = $_.LockedOut
                LastLogonDate     = $_.LastLogonDate
                DistinguishedName = $_.DistinguishedName
            }
        }
    }
    catch {
        Write-Error "Failed to retrieve locked-out users: $_"
    }
}
