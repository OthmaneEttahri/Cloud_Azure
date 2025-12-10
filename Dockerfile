FROM python:3.10-slim

WORKDIR /app

# 1. Installation système + SSH
# On utilise la commande 'bash' qui est plus robuste que sh
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copie du code source
COPY ProjetDjango/ .

# 4. Config SSH
COPY sshd_config /etc/ssh/

# 5. Static files
RUN python manage.py collectstatic --noinput

# 6. Ports et Lancement
EXPOSE 8000 2222

# On utilise CMD (plus souple) au lieu d'ENTRYPOINT
# La commande est simple : Démarrer SSH, puis démarrer Gunicorn
CMD service ssh start && gunicorn --bind 0.0.0.0:8000 ProjetDjango.wsgi:application