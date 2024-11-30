#!/bin/bash
sudo yum update -y

echo "${gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
echo "${ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa

mkdir -p ~/duckdns
echo url="https://www.duckdns.org/update?domains=${duckdns_domain}&token=${duckdns_token}&ip=" | curl -k -o ~/duckdns/duck.log -K -

sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo docker swarm init
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

sudo docker login registry.gitlab.com -u sunba23 -p ${secrets_gitlab_access_token}
