#requires -RunAsAdministrator
<#!
.SYNOPSIS
    Importe des utilisateurs et leurs groupes multiples dans laplateforme.io.
.DESCRIPTION
    À exécuter après la création du domaine laplateforme.io.
    Le script crée les OUs Utilisateurs et Groupes si elles n'existent pas,
    crée les groupes, crée les utilisateurs puis les ajoute à tous leurs groupes.
#>

[CmdletBinding()]
param(
    [string]$CsvPath,
    [switch]$ResetExistingPasswords
)

# Windows PowerShell peut évaluer la valeur par défaut avant de renseigner
# $PSScriptRoot. Le chemin est donc calculé après le bloc paramètre.
if ([string]::IsNullOrWhiteSpace($CsvPath)) {
    $ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
    $CsvPath = Join-Path -Path $ScriptDirectory -ChildPath 'utilisateurs.csv'
}

$ErrorActionPreference = 'Stop'

$DomainName      = 'laplateforme.io'
$DomainDN        = 'DC=laplateforme,DC=io'
$UsersOUName     = 'Utilisateurs'
$GroupsOUName    = 'Groupes'
$UsersOU         = "OU=$UsersOUName,$DomainDN"
$GroupsOU        = "OU=$GroupsOUName,$DomainDN"
$DefaultPassword = ConvertTo-SecureString 'Azerty_2025!' -AsPlainText -Force
$GroupColumns    = @('groupe1', 'groupe2', 'groupe3', 'groupe4', 'groupe5', 'groupe6')

function Ensure-OrganizationalUnit {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -SearchScope OneLevel -ErrorAction SilentlyContinue
    if (-not $existingOU) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $false | Out-Null
        Write-Host "OU créée : $Name" -ForegroundColor Cyan
    }
}

try {
    Import-Module ActiveDirectory

    # Vérifie que le domaine demandé est bien celui utilisé.
    $CurrentDomain = Get-ADDomain
    if ($CurrentDomain.DNSRoot -ne $DomainName) {
        throw "Le domaine courant est $($CurrentDomain.DNSRoot) et non $DomainName. Exécute ce script sur le contrôleur de domaine demandé."
    }

    if (-not (Test-Path -Path $CsvPath -PathType Leaf)) {
        throw "Fichier CSV introuvable : $CsvPath"
    }

    $Users = Import-Csv -Path $CsvPath -Delimiter ',' -Encoding UTF8
    if (-not $Users) {
        throw 'Le fichier CSV est vide.'
    }

    $RequiredColumns = @('nom', 'prenom') + $GroupColumns
    $CsvColumns = $Users[0].PSObject.Properties.Name
    $MissingColumns = $RequiredColumns | Where-Object { $_ -notin $CsvColumns }
    if ($MissingColumns) {
        throw "Colonnes manquantes dans le CSV : $($MissingColumns -join ', ')"
    }

    Ensure-OrganizationalUnit -Name $UsersOUName -Path $DomainDN
    Ensure-OrganizationalUnit -Name $GroupsOUName -Path $DomainDN

    foreach ($User in $Users) {
        $FirstName = ([string]$User.prenom).Trim()
        $LastName  = ([string]$User.nom).Trim()

        if ([string]::IsNullOrWhiteSpace($FirstName) -or [string]::IsNullOrWhiteSpace($LastName)) {
            Write-Warning 'Ligne ignorée : nom ou prénom vide.'
            continue
        }

        # Exemple : MARCELLINE ALEXANDRE devient m.alexandre.
        $SamAccountName = ("{0}.{1}" -f $FirstName.Substring(0, 1), $LastName).ToLower()
        if ($SamAccountName.Length -gt 20) {
            $SamAccountName = $SamAccountName.Substring(0, 20)
        }
        $UserPrincipalName = "$SamAccountName@$DomainName"
        $DisplayName = "$FirstName $LastName"

        $ADUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

        if (-not $ADUser) {
            New-ADUser `
                -Name $DisplayName `
                -GivenName $FirstName `
                -Surname $LastName `
                -DisplayName $DisplayName `
                -SamAccountName $SamAccountName `
                -UserPrincipalName $UserPrincipalName `
                -Path $UsersOU `
                -AccountPassword $DefaultPassword `
                -ChangePasswordAtLogon $true `
                -Enabled $true

            $ADUser = Get-ADUser -Identity $SamAccountName
            Write-Host "Utilisateur créé : $DisplayName ($SamAccountName)" -ForegroundColor Green
        }
        else {
            Write-Host "Utilisateur déjà présent : $DisplayName ($SamAccountName)" -ForegroundColor Yellow

            if ($ResetExistingPasswords) {
                Set-ADAccountPassword -Identity $ADUser -Reset -NewPassword $DefaultPassword
                Set-ADUser -Identity $ADUser -ChangePasswordAtLogon $true
                Write-Host "Mot de passe réinitialisé : $SamAccountName" -ForegroundColor DarkYellow
            }
        }

        foreach ($Column in $GroupColumns) {
            $GroupName = ([string]$User.$Column).Trim()
            if ([string]::IsNullOrWhiteSpace($GroupName)) {
                continue
            }

            $ADGroup = Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue
            if (-not $ADGroup) {
                New-ADGroup `
                    -Name $GroupName `
                    -SamAccountName $GroupName `
                    -GroupCategory Security `
                    -GroupScope Global `
                    -Path $GroupsOU | Out-Null

                $ADGroup = Get-ADGroup -Identity $GroupName
                Write-Host "Groupe créé : $GroupName" -ForegroundColor Cyan
            }

            $AlreadyMember = Get-ADGroupMember -Identity $ADGroup -ErrorAction Stop |
                Where-Object { $_.DistinguishedName -eq $ADUser.DistinguishedName }

            if (-not $AlreadyMember) {
                Add-ADGroupMember -Identity $ADGroup -Members $ADUser
                Write-Host "Ajouté au groupe : $SamAccountName -> $GroupName" -ForegroundColor Magenta
            }
        }
    }

    Write-Host "Import terminé avec succès : $($Users.Count) utilisateurs traités." -ForegroundColor Green
}
catch {
    Write-Host "ERREUR : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
