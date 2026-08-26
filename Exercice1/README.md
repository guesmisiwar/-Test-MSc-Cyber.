# Exercice 1 — Mini-lab Cisco Packet Tracer

Ce dossier contient une solution structurée pour l’exercice 1 du test MSc Cyber. Elle met en place trois bureaux, chacun doté d’un switch, d’un point d’accès Wi-Fi, d’un ordinateur portable, de deux PC fixes et d’un téléphone IP. Le routeur Cisco 1941 assure le routage inter-VLAN, le service DHCP et la sortie vers un Internet simulé.

> **Limite importante :** le fichier `.pkt` est un format propriétaire créé et enregistré par l’application Cisco Packet Tracer. Cette application n’est pas disponible dans l’environnement de préparation. Les fichiers fournis permettent néanmoins de reconstruire le lab fidèlement, en copiant les configurations ci-jointes dans Packet Tracer, puis de l’enregistrer sous le nom demandé.

## 1. Architecture retenue

La topologie utilise un fonctionnement **router-on-a-stick**. Le lien entre `R1-MINILAB` et `SW-BUREAU-1` est un trunk 802.1Q qui transporte les VLAN 1, 10, 20 et 30. Les deux liens entre switchs sont également des trunks. Le troisième switch termine la chaîne ; son port 9 reste disponible pour une extension.

![Schéma de topologie du mini-lab](topologie.png)

Le fichier source modifiable du schéma est également fourni sous le nom `topologie.mmd`.

| Équipement | Nom à donner dans Packet Tracer | Connexion principale |
|---|---|---|
| Routeur Cisco 1941 | `R1-MINILAB` | G0/0 vers SW-BUREAU-1 Fa0/1 ; G0/1 vers R-ISP G0/0 |
| Switch 1 | `SW-BUREAU-1` | Fa0/1 vers R1 ; Fa0/9 vers SW-BUREAU-2 Fa0/1 |
| Switch 2 | `SW-BUREAU-2` | Fa0/1 vers SW-BUREAU-1 ; Fa0/9 vers SW-BUREAU-3 Fa0/1 |
| Switch 3 | `SW-BUREAU-3` | Fa0/1 vers SW-BUREAU-2 ; Fa0/9 réservé en trunk |
| Routeur Internet simulé | `R-ISP` | G0/0 vers R1 ; G0/1 vers SERVER-INTERNET |
| Serveur Internet simulé | `SERVER-INTERNET` | Fa0 vers R-ISP G0/1 |

## 2. Correction de l’incohérence de l’énoncé

L’énoncé contient une contradiction : le tableau d’affectation des ports place les **points d’accès Wi-Fi en VLAN 10** et les **PC fixes en VLAN 20**, alors que le tableau de plan d’adressage inverse les libellés. Cette solution privilégie le tableau d’affectation physique des ports et applique donc la convention suivante.

| VLAN | Usage mis en œuvre | Réseau / passerelle | Attribution DHCP |
|---:|---|---|---|
| 1 | Téléphones IP / VoIP | `192.168.0.0/24` ; `192.168.0.1` | `.10` à `.50` |
| 10 | Wi-Fi et PC portables | `192.168.10.0/24` ; `192.168.10.1` | `.10` à `.50` |
| 20 | PC fixes | `192.168.20.0/24` ; `192.168.20.1` | `.10` à `.50` |
| 30 | Administration et gestion des switchs | `192.168.30.0/24` ; `192.168.30.1` | `.10` à `.50` |

> Si votre formateur exige au contraire de suivre le tableau d’adressage à la lettre, il suffit d’inverser les VLAN affectés aux ports `Fa0/4-5` et `Fa0/6-7` sur les trois switchs, puis de renommer les deux pools DHCP concernés. Une procédure exacte est fournie dans [`ALTERNATIVE_TABLE_ADRESSAGE.md`](ALTERNATIVE_TABLE_ADRESSAGE.md).

## 3. Câblage détaillé

Utilisez des câbles cuivre droit pour tous les raccordements Ethernet. Packet Tracer peut aussi choisir automatiquement le câble avec l’outil **Automatically Choose Connection Type**.

| Bureau | Équipement local | Port de l’équipement local | Port switch | VLAN |
|---|---|---|---|---:|
| 1 | Téléphone IP 1 | FastEthernet0 | SW-BUREAU-1 Fa0/2 | 1 |
| 1 | AP-BUREAU-1 | Port Ethernet | SW-BUREAU-1 Fa0/4 | 10 |
| 1 | PC-FIXE-1A | FastEthernet0 | SW-BUREAU-1 Fa0/6 | 20 |
| 1 | PC-FIXE-1B | FastEthernet0 | SW-BUREAU-1 Fa0/7 | 20 |
| 1 | Poste d’administration facultatif | FastEthernet0 | SW-BUREAU-1 Fa0/8 | 30 |
| 2 | Téléphone IP 2 | FastEthernet0 | SW-BUREAU-2 Fa0/2 | 1 |
| 2 | AP-BUREAU-2 | Port Ethernet | SW-BUREAU-2 Fa0/4 | 10 |
| 2 | PC-FIXE-2A | FastEthernet0 | SW-BUREAU-2 Fa0/6 | 20 |
| 2 | PC-FIXE-2B | FastEthernet0 | SW-BUREAU-2 Fa0/7 | 20 |
| 2 | Poste d’administration facultatif | FastEthernet0 | SW-BUREAU-2 Fa0/8 | 30 |
| 3 | Téléphone IP 3 | FastEthernet0 | SW-BUREAU-3 Fa0/2 | 1 |
| 3 | AP-BUREAU-3 | Port Ethernet | SW-BUREAU-3 Fa0/4 | 10 |
| 3 | PC-FIXE-3A | FastEthernet0 | SW-BUREAU-3 Fa0/6 | 20 |
| 3 | PC-FIXE-3B | FastEthernet0 | SW-BUREAU-3 Fa0/7 | 20 |
| 3 | Poste d’administration facultatif | FastEthernet0 | SW-BUREAU-3 Fa0/8 | 30 |

Les portables ne sont pas reliés au switch par câble : ils se connectent en Wi-Fi à leur point d’accès respectif. Les ports 3, 5 et 8 sont déjà configurés afin de respecter le plan de ports mais ils peuvent rester vacants si aucun équipement supplémentaire n’est ajouté.

## 4. Ordre de mise en œuvre

Commencez par déposer les équipements dans Packet Tracer et réalisez le câblage du tableau précédent. Ajoutez les deux équipements de simulation nécessaires pour tester Internet : un second routeur `R-ISP` et un `Server-PT`.

Ensuite, ouvrez l’interface CLI de chaque switch et collez, dans cet ordre, les fichiers `configs/SW_BUREAU_1.cfg`, `configs/SW_BUREAU_2.cfg` et `configs/SW_BUREAU_3.cfg`. Configurez ensuite `R1-MINILAB` à partir de `configs/R1_1941.cfg`, puis `R-ISP` à partir de `configs/R_ISP.cfg`. Configurez le serveur et les points d’accès à l’aide des guides `configs/SERVER_INTERNET.md` et `configs/POINTS_ACCES_WIFI.md`.

Lorsque les équipements sont configurés, sélectionnez **DHCP** dans `Desktop > IP Configuration` sur les six PC fixes. Connectez les trois portables au SSID `MINILAB-WIFI` avec la clé `MiniLabWifi!2026` et conservez DHCP. Les téléphones IP reçoivent une adresse en VLAN 1 ; aucune configuration IPBX n’est nécessaire, conformément à l’énoncé.

Enfin, enregistrez le travail : `File > Save As` puis donnez le nom `Exercice1_MiniLab_Nom_Prenom.pkt`. Pour chaque équipement IOS, exécutez `show running-config`, copiez le résultat dans un fichier texte et placez ces exports dans le dossier `configs/exports_reels/` de votre dépôt.

## 5. Fichiers fournis

| Fichier | Rôle |
|---|---|
| `configs/R1_1941.cfg` | Configuration complète du routeur principal : VLAN, DHCP, routage et accès WAN. |
| `configs/R_ISP.cfg` | Routeur Internet simulé et routes de retour. |
| `configs/SW_BUREAU_1.cfg` | Switch du premier bureau, connecté au routeur. |
| `configs/SW_BUREAU_2.cfg` | Switch intermédiaire. |
| `configs/SW_BUREAU_3.cfg` | Switch du troisième bureau. |
| `configs/POINTS_ACCES_WIFI.md` | Configuration graphique des trois points d’accès et des portables. |
| `configs/SERVER_INTERNET.md` | Configuration du serveur DNS/HTTP simulant Internet. |
| `VALIDATION.md` | Commandes et résultats à vérifier. |
| `CAPTURES_A_PRENDRE.md` | Liste de captures à joindre au rendu. |
| `ALTERNATIVE_TABLE_ADRESSAGE.md` | Variante si le correcteur impose l’autre lecture de la contradiction. |

## 6. Rendu à déposer

Le dépôt doit contenir au minimum ce `README.md`, le fichier `.pkt` enregistré depuis Packet Tracer, les exports réels des configurations obtenus avec `show running-config` et les captures d’écran décrites dans `CAPTURES_A_PRENDRE.md`. Le test peut ensuite être démontré avec un ping inter-VLAN et l’ouverture de `http://www.minilab.test` depuis un PC ou un portable.

## Référence

La topologie, les équipements, le plan d’adressage, les contraintes de ports et les livrables proviennent de l’énoncé transmis par l’utilisateur : *Tests d’admission MSc Cyber*, exercice 1, « Packet Tracer ».
