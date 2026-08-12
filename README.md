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


<img width="683" height="405" alt="image" src="https://github.com/user-attachments/assets/1c787eb8-bae6-46ae-858d-2858e9297796" />


<img width="481" height="399" alt="image" src="https://github.com/user-attachments/assets/de84ee1a-3314-42d8-90d8-8aa9913d3c87" />


<img width="390" height="213" alt="image" src="https://github.com/user-attachments/assets/7a13a4b3-9b3b-4c36-b739-feed207adbfd" />



<img width="393" height="216" alt="image" src="https://github.com/user-attachments/assets/c672af72-a87c-4b52-9430-d5322d14a2a2" />

<img width="392" height="493" alt="image" src="https://github.com/user-attachments/assets/6b98c69b-1df1-4e1c-a796-01d14fac1b94" />


<img width="394" height="495" alt="image" src="https://github.com/user-attachments/assets/220be5b3-1d06-40d0-91e3-b51288a9a0c5" />

<img width="393" height="500" alt="image" src="https://github.com/user-attachments/assets/4b0177da-2aa6-4495-9258-2f155f71e8ee" />

<img width="440" height="285" alt="image" src="https://github.com/user-attachments/assets/0b7b648c-c4c9-477f-bb3b-f4e7f5523514" />








