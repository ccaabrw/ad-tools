Import-Module ActiveDirectory -ErrorAction Stop

$publicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction Stop

foreach ($function in $publicFunctions) {
    . $function.FullName
}

Export-ModuleMember -Function $publicFunctions.BaseName
