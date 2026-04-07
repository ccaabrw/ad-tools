# Copilot Instructions

## Project Overview

A PowerShell module (**ADTools**) for querying and managing Active Directory objects, including user status queries and group membership management.

## Architecture

```
ADTools/
  ADTools.psd1       # Module manifest
  ADTools.psm1       # Root module — imports ActiveDirectory, dot-sources Public/
  Public/            # One .ps1 file per exported function
    Get-ADUserStatus.ps1
    Add-ADGroupMembership.ps1
    Remove-ADGroupMembership.ps1
    Unlock-ADUserAccount.ps1
    Disable-ADUserAccount.ps1
    Enable-ADUserAccount.ps1
```

- `ADTools.psm1` dot-sources all files in `Public\` and calls `Export-ModuleMember`. New functions go in `Public\` as their own `.ps1` file.
- All AD interaction uses cmdlets from the **ActiveDirectory** module. Do not use ADSI/LDAP directly. The module is imported once in `ADTools.psm1` — do not re-import it inside individual function files.
- Runs on Windows hosts with the AD module available (RSAT or domain controller).
- Functions assume the running user context is already authenticated to the domain. An optional `-Credential` parameter may be included for alternate credentials but must never be mandatory.

## Usage

```powershell
Import-Module .\ADTools\ADTools.psd1
Get-ADUserStatus -Identity jdoe
Add-ADGroupMembership -UserIdentity jdoe -GroupIdentity "VPN-Users"
```

## Conventions

- Each exported function lives in its own file under `Public\`, named `Verb-Noun.ps1` matching the function name.
- Use `-ErrorAction Stop` on AD cmdlets so errors are catchable with `try/catch`.
- Accept input via parameters; use `[CmdletBinding()]` and `param()` blocks.
- Use `SupportsShouldProcess` on all functions that modify AD objects (supports `-WhatIf`).
- Output objects (not formatted strings) so callers can pipe results — use `Write-Output` or return objects, not `Write-Host` for data.
- Use `Write-Verbose` for status/progress messages, not `Write-Host`.

## Common AD Module Cmdlets Used

- `Get-ADUser`, `Set-ADUser`, `Disable-ADAccount`, `Enable-ADAccount`
- `Get-ADGroup`, `Add-ADGroupMember`, `Remove-ADGroupMember`, `Get-ADGroupMember`
- `Get-ADComputer`
- Use `-Properties *` only when needed — specify only required properties for performance.
- Filter at the server side when possible: `-Filter` or `-LDAPFilter` instead of `Where-Object`.
