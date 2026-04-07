# ADTools

A PowerShell module for querying and managing Active Directory objects.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- [RSAT Active Directory module](https://learn.microsoft.com/en-us/powershell/module/activedirectory/) (`ActiveDirectory` module must be available)
- The running user must be authenticated to the domain

## Installation

Clone the repository and import the module directly:

```powershell
git clone https://github.com/ccaabrw/ad-tools.git
Import-Module .\ad-tools\ADTools\ADTools.psd1
```

## Functions

### `Get-ADUserStatus`

Returns account status and details for a user.

```powershell
Get-ADUserStatus -Identity jdoe
```

**Output includes:** `SamAccountName`, `DisplayName`, `EmailAddress`, `Title`, `Department`, `Enabled`, `LockedOut`, `LastLogonDate`, `PasswordLastSet`, `PasswordExpired`, `PasswordNeverExpires`, `AccountExpirationDate`, `Groups`

---

### `Add-ADGroupMembership`

Adds a user to an AD group.

```powershell
Add-ADGroupMembership -UserIdentity jdoe -GroupIdentity "VPN-Users"

# Pipeline support
"jdoe", "jsmith" | Add-ADGroupMembership -GroupIdentity "VPN-Users"
```

---

### `Remove-ADGroupMembership`

Removes a user from an AD group.

```powershell
Remove-ADGroupMembership -UserIdentity jdoe -GroupIdentity "VPN-Users"
```

---

### `Unlock-ADUserAccount`

Unlocks a locked user account. No-ops if the account is not locked.

```powershell
Unlock-ADUserAccount -Identity jdoe
```

---

### `Disable-ADUserAccount`

Disables a user account. No-ops if the account is already disabled.

```powershell
Disable-ADUserAccount -Identity jdoe
```

---

### `Enable-ADUserAccount`

Enables a user account. No-ops if the account is already enabled.

```powershell
Enable-ADUserAccount -Identity jdoe
```

---

## Common Options

All functions support:

- **`-Credential`** — optional alternate credentials (defaults to current user context)
- **`-WhatIf`** — preview changes without applying them (write operations only)
- **`-Verbose`** — show detailed status messages
- **Pipeline input** — pipe usernames or objects directly into any function

## Examples

```powershell
# Check if a user is locked out, then unlock them
$status = Get-ADUserStatus -Identity jdoe
if ($status.LockedOut) { Unlock-ADUserAccount -Identity jdoe }

# Preview disabling multiple users before applying
"jdoe", "jsmith" | Disable-ADUserAccount -WhatIf

# Use alternate credentials
$cred = Get-Credential
Get-ADUserStatus -Identity jdoe -Credential $cred
```

## Adding New Functions

1. Create a new `.ps1` file in `ADTools\Public\` named after the function (e.g. `Reset-ADUserPassword.ps1`)
2. Define the function inside the file using `function Reset-ADUserPassword { ... }`
3. Add the function name to `FunctionsToExport` in `ADTools\ADTools.psd1`

The root module (`ADTools.psm1`) automatically dot-sources everything in `Public\`.
