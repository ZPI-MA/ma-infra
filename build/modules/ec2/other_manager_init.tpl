#!/bin/bash
sudo yum update -y

echo "${gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
echo "${ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa

if [ ! -f /etc/letsencrypt/live/spotiprofile.duckdns.org/fullchain.pem ]; then
  echo "SSL certificates not found. Generating new certificates..."
  sudo amazon-linux-extras install epel -y
  sudo yum install certbot -y
  sudo certbot certonly --standalone --non-interactive --agree-tos --email zpidevteam@gmail.com -d spotiprofile.duckdns.org
else
  echo "SSL certificates found. Skipping generation."
fi

sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

MANAGER_TOKEN=$(aws ssm get-parameter \
  --region ${region} \
  --name "/docker/swarm/manager-token" \
  --with-decryption \
  --query Parameter.Value \
  --output text)
  
MANAGER_IP=$(aws ssm get-parameter \
  --region ${region} \
  --name "/docker/swarm/manager-ip" \
  --query Parameter.Value \
  --output text)

echo "${secrets_gitlab_registry_token}" | docker login registry.gitlab.com -u ${secrets_gitlab_registry_username} --password-stdin

sudo docker swarm join --token $MANAGER_TOKEN $MANAGER_IP:2377
