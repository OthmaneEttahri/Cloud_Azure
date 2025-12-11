FROM python:3.10-slim

WORKDIR /app

#  Installation SSH
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc libpq-dev openssh-server \
    && echo "root:Docker!" | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Config SSH
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

# Dependances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copie code source
COPY ProjetDjango/ .

# 5. Static files
RUN python manage.py collectstatic --noinput

# 6. Ports (Web + SSH Azure)
EXPOSE 8000 2222

#DÉMARRAGE ROBUSTE

CMD mkdir -p /run/sshd && ssh-keygen -A && /usr/sbin/sshd && gunicorn --bind 0.0.0.0:8000 ProjetDjango.wsgi:application