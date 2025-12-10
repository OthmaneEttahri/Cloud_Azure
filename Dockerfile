FROM python:3.10-slim

WORKDIR /app

# 1. Installation de SSH et dépendances système
# On définit le mot de passe root à "Docker!" (OBLIGATOIRE pour Azure)
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Génération de la configuration SSH directement ici
# (On évite les fichiers externes corrompus par Windows)
RUN echo "Port 2222" > /etc/ssh/sshd_config \
    && echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config \
    && echo "LoginGraceTime 180" >> /etc/ssh/sshd_config \
    && echo "X11Forwarding yes" >> /etc/ssh/sshd_config \
    && echo "Ciphers aes128-cbc,3des-cbc,aes256-cbc" >> /etc/ssh/sshd_config \
    && echo "MACs hmac-sha1,hmac-sha1-96" >> /etc/ssh/sshd_config \
    && echo "StrictModes yes" >> /etc/ssh/sshd_config \
    && echo "SyslogFacility DAEMON" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config

# 3. Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copie du code source
COPY ProjetDjango/ .

# 5. Static files
RUN python manage.py collectstatic --noinput

# 6. Ports (Web + SSH Azure)
EXPOSE 8000 2222

# 7. COMMANDE DE DÉMARRAGE ROBUSTE
# - mkdir -p /run/sshd : Crée le dossier indispensable
# - ssh-keygen -A : GÉNÈRE LES CLÉS DE SÉCURITÉ (C'est souvent ça qui manque !)
# - /usr/sbin/sshd : Lance SSH en mode démon
# - gunicorn : Lance le site
CMD mkdir -p /run/sshd && ssh-keygen -A && /usr/sbin/sshd && gunicorn --bind 0.0.0.0:8000 ProjetDjango.wsgi:application