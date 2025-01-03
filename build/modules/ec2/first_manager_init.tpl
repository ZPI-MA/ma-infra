#!/bin/bash
sudo yum update -y

echo "${gitlab_ssh_public}" | sudo tee -a /home/ec2-user/.ssh/authorized_keys
sudo chmod 600 ~/.ssh/id_rsa

mkdir -p ~/duckdns
echo url="https://www.duckdns.org/update?domains=${duckdns_domain}&token=${duckdns_token}&ip=" | curl -k -o ~/duckdns/duck.log -K -

if [ ! -f /etc/letsencrypt/live/spotiprofile.duckdns.org/fullchain.pem ]; then
  echo "SSL certificates not found. Generating new certificates..."
  sudo amazon-linux-extras install epel -y
  sudo yum install certbot -y
  sudo certbot certonly --standalone --non-interactive --agree-tos --email zpidevteam@gmail.com -d spotiprofile.duckdns.org
else
  echo "SSL certificates found. Skipping generation."
fi

sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras install postgresql15

sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "${secrets_gitlab_registry_token}" | docker login registry.gitlab.com -u ${secrets_gitlab_registry_username} --password-stdin

docker swarm init
MANAGER_TOKEN=$(sudo docker swarm join-token manager -q)

aws ssm put-parameter \
  --region ${region} \
  --name "/docker/swarm/manager-token" \
  --value "$MANAGER_TOKEN" \
  --type SecureString \
  --overwrite
aws ssm put-parameter \
  --region ${region} \
  --name "/docker/swarm/manager-ip" \
  --value "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)" \
  --type String \
  --overwrite

printf "${secrets_spotify_client_id}" | sudo docker secret create spotify_client_id -
printf "${secrets_spotify_client_secret}" | sudo docker secret create spotify_client_secret -
printf "${secrets_database_user}" | sudo docker secret create db_user -
printf "${secrets_database_password}" | sudo docker secret create db_password -
printf "${secrets_database_host}" | sudo docker secret create db_host -
sudo docker secret create ssl_cert /etc/letsencrypt/live/spotiprofile.duckdns.org/fullchain.pem
sudo docker secret create ssl_key /etc/letsencrypt/live/spotiprofile.duckdns.org/privkey.pem
