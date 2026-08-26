# Exercice 3 — Déploiement WordPress conteneurisé

## Objectif

Cet exercice déploie la dernière version de WordPress avec Docker Compose en séparant trois services : MariaDB pour la base de données, WordPress avec PHP-FPM pour l’exécution PHP et Nginx comme serveur Web/reverse proxy. Le volume `wp_shared_data` est partagé entre WordPress et Nginx afin que les fichiers WordPress soient accessibles aux deux conteneurs.

## Architecture

| Service Docker | Image | Rôle | Exposition |
|---|---|---|---|
| `db` | `mariadb:latest` | Stockage persistant de la base de données WordPress. | Réseau Docker interne uniquement. |
| `wordpress` | `wordpress:fpm` | WordPress et moteur PHP-FPM. | Réseau Docker interne sur le port 9000. |
| `nginx` | `nginx:latest` | Serveur Web, fichiers statiques et reverse proxy FastCGI vers PHP-FPM. | Port 80 de l’hôte. |

| Volume | Utilisation |
|---|---|
| `db_data` | Persistance des données MariaDB dans `/var/lib/mysql`. |
| `wp_shared_data` | Volume commun entre WordPress et Nginx dans `/var/www/html`. |

## Fichiers du projet

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | Définit les services MariaDB, WordPress PHP-FPM et Nginx, les réseaux et les volumes. |
| `nginx.conf` | Configuration Nginx qui transmet les requêtes PHP vers `wordpress:9000`. |
| `Guide_Execution_Tounsi.md` | Guide simplifié, étape par étape, pour lancer le projet et prendre les captures. |

## Démarrage

Se placer dans le dossier contenant les fichiers puis exécuter :

```bash
docker compose up -d
```

Docker télécharge les images si elles ne sont pas encore présentes, crée les volumes et démarre les trois conteneurs en arrière-plan.

## Vérifications

Vérifier que les conteneurs sont actifs :

```bash
docker compose ps
```

La sortie attendue affiche les conteneurs `mariadb_db`, `wordpress_php` et `nginx_proxy` avec le statut `running` ou `Up`. Nginx doit exposer `0.0.0.0:80->80/tcp`.

Vérifier la configuration Nginx chargée :

```bash
docker compose exec nginx nginx -t
```

Ouvrir ensuite le navigateur à l’adresse suivante :

```text
http://localhost
```

Si Docker s’exécute dans une machine virtuelle ou un serveur différent du navigateur, utiliser l’adresse IP de la machine Docker :

```text
http://IP_DE_LA_MACHINE
```

La page d’installation WordPress doit s’afficher. Terminer l’installation dans le navigateur en choisissant la langue, le titre du site et le compte administrateur WordPress.

## Arrêt et relance

| Action | Commande |
|---|---|
| Arrêter les conteneurs sans effacer les données | `docker compose down` |
| Relancer les conteneurs | `docker compose up -d` |
| Voir les journaux Nginx | `docker compose logs nginx` |
| Voir les journaux WordPress PHP-FPM | `docker compose logs wordpress` |
| Effacer aussi les volumes (attention : supprime les données) | `docker compose down -v` |

## Captures demandées pour le rendu

| Capture | Action à montrer | Preuve apportée |
|---|---|---|
| `docker_status_v2.png` | Résultat de `docker compose ps` ou `docker ps`. | Les trois services sont actifs. |
| `wordpress_success_demo.png` | Page WordPress ouverte dans le navigateur sur le port 80. | WordPress est servi via Nginx et PHP-FPM. |

## Conclusion

Cette réalisation répond à l’exercice en isolant la base MariaDB, l’application WordPress/PHP-FPM et le reverse proxy Nginx. Les volumes assurent la persistance de la base et le partage des fichiers WordPress entre PHP-FPM et Nginx.
