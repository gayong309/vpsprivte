FROM ubuntu:22.04

ARG NGROK_TOKEN
ARG PASSWORD=rootuser
ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3 python3-pip python3-venv \
    mariadb-server mariadb-client nginx \
    && apt clean

# Install Python requests module
RUN pip3 install requests

# Install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && rm ngrok.zip \
    && mkdir /run/sshd

# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Setup Pterodactyl Panel
RUN mkdir -p /var/www/pterodactyl \
    && cd /var/www/pterodactyl \
    && curl -LO https://github.com/pterodactyl/panel/releases/download/v1.8.1/panel.tar.gz \
    && tar -xzvf panel.tar.gz \
    && rm panel.tar.gz

# Add setup script and Python script
COPY setup.sh /setup.sh
COPY get_ngrok_info.py /get_ngrok_info.py
RUN chmod +x /setup.sh /get_ngrok_info.py

# Configure SSH and ngrok
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo root:${PASSWORD} | chpasswd \
    && echo "#!/bin/bash" > /docker.sh \
    && echo "/ngrok tcp 22 --authtoken ${NGROK_TOKEN} &" >> /docker.sh \
    && echo "sleep 5" >> /docker.sh \
    && echo "python3 /get_ngrok_info.py ${PASSWORD}" >> /docker.sh \
    && echo '/usr/sbin/sshd -D' >> /docker.sh \
    && chmod +x /docker.sh

EXPOSE 22

CMD ["/bin/bash", "/docker.sh"]
