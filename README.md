# Projet Azure

## Overview

Ce projet est une application de stockage de fichiers en ligne (similaire à Google Drive) développée avec Django, conteneurisée avec Docker, et déployée automatiquement sur Microsoft Azure via Terraform et GitHub Actions.


## Features

Authentification Sécurisée : Inscription et Connexion/Déconnexion.

Gestion de Fichiers :

Upload de fichiers (limite 40 Mo).

Stockage persistant sur le Cloud (Azure Blob).

Téléchargement, Renommage, Suppression.

Organisation : Création de dossiers et déplacement de fichiers.

Statistiques : Visualisation graphique de la répartition des types de fichiers (PDF, Images, Vidéos) via matplotlib.

Interface : Responsive design avec un mode Sombre/Clair.

## Guide de Démarrage (Local)

### Pour tester l'application sur votre machine sans Azure :

Cloner le projet :

git clone git@github.com:OthmaneEttahri/Cloud_Azure.git
cd ProjetDjango

Installer les dépendances :

pip install -r requirements.txt


Lancer les migrations et créer un admin :

python manage.py migrate

python manage.py createsuperuser

Lancer le serveur :

python manage.py runserver

Accédez à http://127.0.0.1:8000.

### ☁️ Déploiement sur Azure (Production)

Le déploiement est entièrement automatisé, mais nécessite une initialisation de l'infrastructure.

1. Provisionner l'infrastructure (Terraform)
Dans le dossier terraform/ :

az login
terraform init
terraform apply -var="django_secret_key=VOTRE_CLE_SECRETE"
pour récupérer la clé secrète : terraform output -raw acr_admin_password

Cela va créer toutes les ressources Azure et configurer les variables d'environnement nécessaires.

2. Déploiement Continu (CI/CD)
Une fois l'infrastructure en place, tout git push sur la branche main déclenche le workflow GitHub Actions qui met à jour le site en quelques minutes.

3. Initialisation de la Base de Données (Post-Déploiement)
⚠️ Note importante sur SQLite en Docker : Ce projet utilise SQLite pour la démonstration. Dans un conteneur Docker, le fichier SQLite est réinitialisé à chaque redémarrage du conteneur. Pour initialiser le site après un déploiement, il faut se connecter en SSH via le Portail Azure :

Aller sur la ressource Web App > Outils de développement > SSH.

Exécuter les commandes suivantes sur le terminal SSH :

cd /app
python manage.py migrate
python manage.py createsuperuser


## Conclusion milestones

Application Web	✅ Fait	Django 5.x avec interface utilisateur complète.

Conteneurisation	✅ Fait	Dockerfile optimisé (multi-stage non requis ici car Python), image légère slim.

Infrastructure as Code	✅ Fait	Terraform complet (main.tf) pour provisionner Azure.

Pipeline CI/CD	✅ Fait	GitHub Actions pour Build & Deploy automatique.

Stockage Cloud	✅ Fait	Utilisation d'Azure Blob Storage pour la persistance des médias.

Sécurité	✅ Fait	Gestion des secrets (GitHub Secrets), HTTPS géré par Azure, CSRF protection Django.
