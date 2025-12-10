FROM python:3.10-slim

WORKDIR /app

# 1. Installation système + SSH
# On installe openssh-server et on définit le mot de passe root
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- FIX CRITIQUE SSH ---
# Création du dossier indispensable pour que SSH démarre
RUN mkdir -p /run/sshd
# ------------------------

# 2. Installation dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copie du code
COPY ProjetDjango/ .

# 4. Config SSH (Assure-toi que le fichier sshd_config est bien à la racine de ton projet)
COPY sshd_config /etc/ssh/

# 5. Static files
RUN python manage.py collectstatic --noinput

# 6. Ports (Web + SSH)
EXPOSE 8000 2222

# 7. Commande de démarrage ROBUSTE
# On lance sshd directement (pas via service) puis Gunicorn
CMD ["sh", "-c", "/usr/sbin/sshd && gunicorn --bind 0.0.0.0:8000 ProjetDjango.wsgi:application"]