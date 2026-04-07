# Copilot Instructions

## Project Overview

A collection of PowerShell scripts for querying and managing Active Directory objects, including user status queries and group membership management.

## Architecture

- Scripts are standalone `.ps1` files targeting specific AD operations (e.g., user queries, group management).
- All AD interaction uses cmdlets from the **ActiveDirectory** module (`Import-Module ActiveDirectory`). Do not use ADSI/LDAP directly.
- Scripts are designed to run on Windows hosts with the AD module available (RSAT or domain controller).
- Scripts assume the running user context is already authenticated to the domain — no credential loading required. Scripts may include an optional `-Credential` parameter for cases where alternate credentials are needed, but it should never be mandatory.

## Conventions

- Always import the AD module at the top of each script: `Import-Module ActiveDirectory -ErrorAction Stop`
- Use `-ErrorAction Stop` on AD cmdlets so errors are catchable with `try/catch`.
- Accept input via parameters (not hard-coded values); use `[CmdletBinding()]` and `param()` blocks.
- Output objects (not formatted strings) so callers can pipe results — use `Write-Output` or return objects, not `Write-Host` for data.
- Use `Write-Host` or `Write-Verbose` only for status/progress messages, not for data output.
- Name scripts as `Verb-NounTarget.ps1` following PowerShell verb conventions (`Get-`, `Set-`, `Add-`, `Remove-`).

## Common AD Module Cmdlets Used

- `Get-ADUser`, `Set-ADUser`, `Disable-ADAccount`, `Enable-ADAccount`
- `Get-ADGroup`, `Add-ADGroupMember`, `Remove-ADGroupMember`, `Get-ADGroupMember`
- `Get-ADComputer`
- Use `-Properties *` only when needed — specify only required properties for performance.
- Filter at the server side when possible: `-Filter` or `-LDAPFilter` instead of `Where-Object`.
