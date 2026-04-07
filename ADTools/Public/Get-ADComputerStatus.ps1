<#
.SYNOPSIS
    Returns status information for an Active Directory computer account.

.PARAMETER Identity
    The name, SamAccountName, or DistinguishedName of the computer.

.PARAMETER Credential
    Optional alternate credentials. Defaults to the current user context.

.EXAMPLE
    Get-ADComputerStatus -Identity DESKTOP-01

.EXAMPLE
    "DESKTOP-01","LAPTOP-02" | Get-ADComputerStatus
#>
function Get-ADComputerStatus {
    [CmdletBinding()]
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
        $properties = @(
            'Enabled',
            'LastLogonDate',
            'OperatingSystem',
            'OperatingSystemVersion',
            'IPv4Address',
            'MemberOf',
            'Description',
            'Created',
            'Modified'
        )

        try {
            $computer = Get-ADComputer -Identity $Identity -Properties $properties @adParams -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve computer '$Identity': $_"
            return
        }

        $groups = $computer.MemberOf | ForEach-Object {
            (Get-ADGroup -Identity $_ @adParams).Name
        } | Sort-Object

        [PSCustomObject]@{
            Name                   = $computer.Name
            DNSHostName            = $computer.DNSHostName
            Enabled                = $computer.Enabled
            OperatingSystem        = $computer.OperatingSystem
            OperatingSystemVersion = $computer.OperatingSystemVersion
            IPv4Address            = $computer.IPv4Address
            LastLogonDate          = $computer.LastLogonDate
            Description            = $computer.Description
            Created                = $computer.Created
            Modified               = $computer.Modified
            Groups                 = $groups
        }
    }
}
