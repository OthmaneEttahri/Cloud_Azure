FROM python:3.10-slim

WORKDIR /app

# 1. Installation système + SSH
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Copie et installation des requirements
# --- CORRECTION ICI ---
# On copie d'abord le fichier dans le conteneur
COPY requirements.txt . 
# Ensuite on lance l'installation
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copie du code source (Le dossier ProjetDjango vers /app)
COPY ProjetDjango/ .

# 4. Config SSH & Entrypoint
COPY sshd_config /etc/ssh/
COPY entrypoint.sh .

# --- CORRECTION WINDOWS (CRLF -> LF) ---
RUN sed -i 's/\r$//g' entrypoint.sh
RUN chmod +x entrypoint.sh

# 5. Static files
RUN python manage.py collectstatic --noinput

# 6. Ports et Lancement
EXPOSE 8000 2222
ENTRYPOINT ["./entrypoint.sh"]