# Script d'importation Active Directory pour laplateforme.io
# Ce script automatise la création des groupes et des utilisateurs à partir d'un fichier CSV.

# 1. Configuration du Mot de passe par défaut
$Password = ConvertTo-SecureString "Azerty_2025!" -AsPlainText -Force

# 2. Chemin du fichier CSV
$CSVPath = "C:\utilisateurs.csv"

# 3. Importation des données (délimiteur virgule)
$Users = Import-Csv $CSVPath -Delimiter ','

foreach ($User in $Users) {
    # Génération du SamAccountName (ex: m.alexandre)
    $SAM = ($User.prenom[0] + "." + $User.nom).ToLower()
    
    # Création de l'utilisateur s'il n'existe pas déjà
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$SAM'")) {
        New-ADUser -Name "$($User.prenom) $($User.nom)" `
                   -SamAccountName $SAM `
                   -UserPrincipalName "$SAM@laplateforme.io" `
                   -AccountPassword $Password `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true
        
        Write-Host "Succès : Utilisateur $SAM créé !" -ForegroundColor Green
    } else {
        Write-Host "Info : L'utilisateur $SAM existe déjà." -ForegroundColor Yellow
    }

    # 4. Gestion des groupes (jusqu'à 6 groupes par utilisateur)
    $GroupFields = @("groupe1", "groupe2", "groupe3", "groupe4", "groupe5", "groupe6")
    foreach ($Field in $GroupFields) {
        $GroupName = $User.$Field
        if ($GroupName -and $GroupName.Trim() -ne "") {
            # Création du groupe s'il n'existe pas
            if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'")) {
                New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global
                Write-Host "Groupe $GroupName créé." -ForegroundColor Cyan
            }
            # Ajout de l'utilisateur au groupe
            Add-ADGroupMember -Identity $GroupName -Members $SAM
        }
    }
}
