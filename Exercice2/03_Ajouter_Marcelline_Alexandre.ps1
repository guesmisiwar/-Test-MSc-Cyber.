#requires -RunAsAdministrator
# Correction du conflit : m.alexandre est déjà utilisé par un ancien compte.
# Le compte demandé est donc créé sous ma.alexandre.

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$SamAccountName = 'ma.alexandre'
$UserOU = 'OU=Utilisateurs,DC=laplateforme,DC=io'
$Password = ConvertTo-SecureString 'Azerty_2025!' -AsPlainText -Force

try {
    $User = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

    if (-not $User) {
        New-ADUser `
            -Name 'MARCELLINE ALEXANDRE' `
            -GivenName 'MARCELLINE' `
            -Surname 'ALEXANDRE' `
            -DisplayName 'MARCELLINE ALEXANDRE' `
            -SamAccountName $SamAccountName `
            -UserPrincipalName "$SamAccountName@laplateforme.io" `
            -Path $UserOU `
            -AccountPassword $Password `
            -ChangePasswordAtLogon $true `
            -Enabled $true

        $User = Get-ADUser -Identity $SamAccountName
        Write-Host 'Utilisateur créé : MARCELLINE ALEXANDRE (ma.alexandre)' -ForegroundColor Green
    }

    $IsMember = Get-ADGroupMember -Identity 'Animation' | Where-Object { $_.SamAccountName -eq $SamAccountName }
    if (-not $IsMember) {
        Add-ADGroupMember -Identity 'Animation' -Members $User
        Write-Host 'Ajouté au groupe : ma.alexandre -> Animation' -ForegroundColor Magenta
    }

    Write-Host 'Correction terminée avec succès.' -ForegroundColor Green
}
catch {
    Write-Host "ERREUR : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
