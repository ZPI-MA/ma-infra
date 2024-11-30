#!/bin/bash
sudo yum update -y

echo "${gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
echo "${ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa

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

sudo docker login registry.gitlab.com -u sunba23 -p ${secrets_gitlab_access_token}

sudo docker swarm join --token $MANAGER_TOKEN $MANAGER_IP:2377
