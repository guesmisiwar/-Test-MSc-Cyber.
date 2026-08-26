#requires -RunAsAdministrator
<#!
.SYNOPSIS
    Installe Active Directory Domain Services et crée la forêt laplateforme.io.
.DESCRIPTION
    À exécuter sur un Windows Server 20xx fraîchement installé, en tant qu'administrateur.
    Le serveur redémarrera automatiquement à la fin de la promotion en contrôleur de domaine.
#>

$ErrorActionPreference = 'Stop'

$DomainName    = 'laplateforme.io'
$NetbiosName   = 'LAPLATEFORME'
$DsrmPassword  = ConvertTo-SecureString 'Azerty_2025!' -AsPlainText -Force

try {
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    if ($ComputerSystem.PartOfDomain) {
        throw "Ce serveur appartient déjà à un domaine : $($ComputerSystem.Domain). Utilise un Windows Server fraîchement installé."
    }

    Write-Host 'Installation du rôle AD DS...' -ForegroundColor Cyan
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null

    Write-Host "Création de la forêt $DomainName..." -ForegroundColor Cyan
    Import-Module ADDSDeployment

    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetbiosName `
        -InstallDNS `
        -SafeModeAdministratorPassword $DsrmPassword `
        -Force
}
catch {
    Write-Host "ERREUR : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
