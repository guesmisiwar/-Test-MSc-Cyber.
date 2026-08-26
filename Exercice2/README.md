# Exercice 2 — Identity Management avec Active Directory

**Domaine créé :** `laplateforme.io`  
**Mot de passe initial de tous les utilisateurs :** `Azerty_2025!`  
**Changement du mot de passe à la première connexion :** activé.

## Objectif

Ce projet répond à l’exercice Active Directory. Il automatise, à l’aide de PowerShell, la création du domaine `laplateforme.io`, l’import de 17 utilisateurs depuis un fichier CSV et la gestion de leurs appartenances à plusieurs groupes.

## Fichiers fournis

| Fichier | Rôle |
|---|---|
| `01_Creer_Domaine_laplateforme.ps1` | Installe le rôle AD DS et crée la forêt Active Directory `laplateforme.io`. |
| `02_Importer_Utilisateurs_AD.ps1` | Crée les OUs, groupes et utilisateurs à partir du CSV. |
| `utilisateurs.csv` | Contient les 17 utilisateurs et leurs groupes (`groupe1` à `groupe6`). |
| `Rendu_Exercice2_ActiveDirectory.docx` | Document de rendu à compléter avec les captures réelles. |

## Préparation du serveur

Utiliser un **Windows Server 20xx fraîchement installé**. Il est préférable de donner une adresse IP statique au serveur avant de commencer. Ouvrir ensuite **Windows PowerShell en tant qu’administrateur**.

Créer le dossier de travail `C:\AD` puis copier les trois fichiers PowerShell/CSV dedans. Dans PowerShell administrateur, exécuter :

```powershell
New-Item -Path 'C:\AD' -ItemType Directory -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
cd C:\AD
```

## Étape 1 — Créer le domaine Active Directory

Dans le dossier `C:\AD`, exécuter :

```powershell
.\01_Creer_Domaine_laplateforme.ps1
```

Le script installe les services de domaine Active Directory, le DNS et crée la forêt `laplateforme.io`. Le serveur redémarre à la fin de la promotion.

Après le redémarrage, ouvrir la session avec :

```text
LAPLATEFORME\Administrator
```

et le mot de passe défini pendant l’installation du serveur.

## Étape 2 — Importer utilisateurs et groupes

Ouvrir à nouveau PowerShell **en administrateur**, puis lancer :

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
cd C:\AD
.\02_Importer_Utilisateurs_AD.ps1
```

Le script effectue les actions suivantes :

1. Il vérifie que le domaine courant est `laplateforme.io`.
2. Il crée les OUs `Utilisateurs` et `Groupes`.
3. Il crée les groupes absents dans l’OU `Groupes`.
4. Il crée les 17 utilisateurs dans l’OU `Utilisateurs`.
5. Il leur attribue le mot de passe initial `Azerty_2025!`.
6. Il active le changement de mot de passe obligatoire à la première connexion.
7. Il ajoute chaque utilisateur à tous les groupes renseignés dans le CSV.

Le script peut être lancé une deuxième fois sans recréer les mêmes comptes. Pour réinitialiser le mot de passe de comptes déjà présents et forcer à nouveau le changement à la connexion, utiliser :

```powershell
.\02_Importer_Utilisateurs_AD.ps1 -ResetExistingPasswords
```

## Vérifications PowerShell

Les commandes suivantes permettent de produire des preuves de fonctionnement :

```powershell
# Vérifier le domaine
Get-ADDomain

# Afficher les utilisateurs créés
Get-ADUser -Filter * -SearchBase 'OU=Utilisateurs,DC=laplateforme,DC=io' `
  -Properties PasswordExpired,PasswordNeverExpires |
  Select-Object Name,SamAccountName,UserPrincipalName,Enabled,PasswordExpired

# Vérifier les groupes et le nombre de membres
Get-ADGroup -Filter * -SearchBase 'OU=Groupes,DC=laplateforme,DC=io' |
  ForEach-Object {
    [PSCustomObject]@{
      Groupe = $_.Name
      Membres = (Get-ADGroupMember -Identity $_).Count
    }
  } | Sort-Object Groupe

# Prouver les groupes multiples de Marc THILLOT
Get-ADPrincipalGroupMembership 'm.thillot' | Select-Object Name
```

## Vérification graphique

Ouvrir **Server Manager > Tools > Active Directory Users and Computers**. Développer le domaine `laplateforme.io`, puis vérifier les OUs `Utilisateurs` et `Groupes`.

Pour vérifier l’appartenance de Marc THILLOT à plusieurs groupes : ouvrir **Utilisateurs > Marc THILLOT > Properties > Member Of**. Les groupes attendus sont `Directeur`, `Cadres`, `Hébergement`, `Technique`, `Administratif` et `Animation`.

Pour vérifier l’obligation de changer le mot de passe : ouvrir les propriétés d’un utilisateur, onglet **Account**, et contrôler la case **User must change password at next logon**.

## Captures obligatoires à faire

| N° | Capture réelle à prendre | Preuve apportée |
|---|---|---|
| 1 | PowerShell après l’exécution de `01_Creer_Domaine_laplateforme.ps1` ou après redémarrage avec `Get-ADDomain` | Domaine `laplateforme.io` créé. |
| 2 | PowerShell après l’exécution de `02_Importer_Utilisateurs_AD.ps1` | Import automatique réussi. |
| 3 | Active Directory Users and Computers : OU `Utilisateurs` | Comptes utilisateurs créés. |
| 4 | Active Directory Users and Computers : OU `Groupes` | Groupes créés. |
| 5 | Propriétés de Marc THILLOT, onglet `Member Of` | Appartenance multi-groupes. |
| 6 | Propriétés d’un utilisateur, onglet `Account` | Changement de mot de passe à la prochaine connexion. |

## Limite de validation

Les scripts ont été vérifiés de manière statique dans le pack. Leur exécution doit être faite sur un véritable Windows Server avec les droits administrateur ; elle ne peut pas être simulée dans l’environnement de préparation de ce dossier.
