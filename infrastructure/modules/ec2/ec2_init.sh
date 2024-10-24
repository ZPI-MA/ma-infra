#!/bin/bash
apt update
mkdir -p /root/.ssh
echo "${gitlab_ssh_public}" | tee -a /root/.ssh/known_hosts
command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | bash; }
echo "${ec2_ssh_private}" | tee -a /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
mkdir -p /run/secrets

# Create the .ini file
cat << 'ENDFILE' | tee /run/secrets/secrets.ini
${secrets_ini}
ENDFILE

chmod 600 /run/secrets/secrets.ini
