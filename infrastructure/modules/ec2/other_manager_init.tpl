#!/bin/bash
sudo apt update
echo "${gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
echo "${ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa
command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
sudo usermod -aG docker ubuntu

sleep 15
FIRST_MANAGER_IP=${first_manager_ip}
echo "first manager ip is $FIRST_MANAGER_IP"

until JOIN_TOKEN=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$FIRST_MANAGER_IP 'sudo docker swarm join-token manager -q') \
  && sudo docker swarm join --token $JOIN_TOKEN $FIRST_MANAGER_IP:2377
do
  echo "Retrying manager join in 10 seconds..."
  sleep 10
done
