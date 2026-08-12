# -Test-MSc-Cyber.
Test d'admission MSc Cyber.
# Exercice 01 : Création d'un MiniLab Réseau (Cisco Packet Tracer)

## 1. Introduction du Projet
L'objectif de cet exercice était de concevoir une infrastructure réseau segmentée pour une entreprise répartie sur trois bureaux, en utilisant des équipements Cisco (Router 1941, Switchs-PT, Access Points).

## 2. Architecture Technique
Le réseau est basé sur une topologie **Router-on-a-Stick** avec les configurations suivantes :
- **VLAN 1 (VoIP) :** 192.168.0.0/24
- **VLAN 10 (PC Fixes) :** 192.168.10.0/24
- **VLAN 20 (Wi-Fi) :** 192.168.20.0/24
- **VLAN 30 (Administration) :** 192.168.30.0/24

## 3. Processus de Configuration
### Configuration des Switchs
- Création des VLANs sur chaque switch.
- Assignation des ports d'accès selon le cahier des charges (Ports 2-3 pour VoIP, 4-5 pour AP, 6-7 pour PC).
- Configuration des ports **Trunk** (1 et 9) en utilisant des câbles **Copper Cross-Over** pour assurer la connectivité entre les switchs.

### Configuration du Routeur
- Activation de l'interface `GigabitEthernet 0/0`.
- Création de sous-interfaces avec encapsulation `dot1Q` pour chaque VLAN.
- Mise en place d'un serveur **DHCP** pour distribuer automatiquement les adresses IP (plage .10 à .50).

## 4. Tests et Vérification
Les tests suivants ont été effectués avec succès :
- **Attribution DHCP :** Tous les équipements reçoivent une adresse IP dans la plage correcte.
- **Connectivité Inter-VLAN :** Ping réussi entre le PC0 (Bureau 1) et le PC2 (Bureau 2).
- **Wi-Fi :** Connexion des Laptops via les Access Points.

<img width="635" height="407" alt="image" src="https://github.com/user-attachments/assets/75f0defb-1f85-46b1-a4f6-1c2f6db6c650" />
<img width="635" height="407" alt="image" src="https://github.com/user-attachments/assets/12c5c90c-0daa-44a2-9586-550acd30ec5a" /><img width="635" height="407" alt="image" src="https://github.com/user-attachments/assets/30e1623e-06b0-4ddf-b038-9d26a603f158" />


