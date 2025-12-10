FROM python:3.10-slim

WORKDIR /app

# 1. Installation système + SSH
# On définit le mot de passe root à "Docker!" (requis par Azure)
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Copie des fichiers
COPY ProjetDjango/requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt

COPY ProjetDjango/ .

# 3. Config SSH & Entrypoint
COPY sshd_config /etc/ssh/
COPY entrypoint.sh .

# --- CORRECTION WINDOWS (CRLF -> LF) ---
# Cette ligne est vitale pour éviter le plantage du script
RUN sed -i 's/\r$//g' entrypoint.sh
RUN chmod +x entrypoint.sh

# 4. Static files
RUN python manage.py collectstatic --noinput

# 5. Ports et Lancement
EXPOSE 8000 2222
ENTRYPOINT ["./entrypoint.sh"]