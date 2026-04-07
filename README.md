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

### `Reset-ADUserPassword`

Resets a user's password. Optionally forces a password change at next logon.

```powershell
$pwd = Read-Host "New password" -AsSecureString
Reset-ADUserPassword -Identity jdoe -NewPassword $pwd
Reset-ADUserPassword -Identity jdoe -NewPassword $pwd -MustChangePasswordAtLogon
```

---

### `Get-ADGroupMembers`

Lists all members of a group. Use `-Recursive` to expand nested groups.

```powershell
Get-ADGroupMembers -Identity "VPN-Users"
Get-ADGroupMembers -Identity "Domain Admins" -Recursive
```

---

### `Get-ADLockedOutUsers`

Returns all locked-out user accounts across the domain, or scoped to an OU.

```powershell
Get-ADLockedOutUsers
Get-ADLockedOutUsers -SearchBase "OU=Employees,DC=contoso,DC=com"
```

---

### `Get-ADComputerStatus`

Returns status information for a computer account.

```powershell
Get-ADComputerStatus -Identity DESKTOP-01

# Pipeline support
"DESKTOP-01","LAPTOP-02" | Get-ADComputerStatus
```

**Output includes:** `Name`, `DNSHostName`, `Enabled`, `OperatingSystem`, `OperatingSystemVersion`, `IPv4Address`, `LastLogonDate`, `Description`, `Created`, `Modified`, `Groups`

---

## Common Options

All functions support:

- **`-Credential`** — optional alternate credentials (defaults to current user context)
- **`-Verbose`** — show detailed status messages

Write operations (`Add/Remove-ADGroupMembership`, `Unlock/Disable/Enable-ADUserAccount`, `Reset-ADUserPassword`) also support:

- **`-WhatIf`** — preview changes without applying them

Most functions accept pipeline input for their primary identity parameter.

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

# Find and unlock all locked-out users
Get-ADLockedOutUsers | Unlock-ADUserAccount
```

## Adding New Functions

1. Create a new `.ps1` file in `ADTools\Public\` named after the function (e.g. `Reset-ADUserPassword.ps1`)
2. Define the function inside the file using `function Reset-ADUserPassword { ... }`
3. Add the function name to `FunctionsToExport` in `ADTools\ADTools.psd1`

The root module (`ADTools.psm1`) automatically dot-sources everything in `Public\`.
