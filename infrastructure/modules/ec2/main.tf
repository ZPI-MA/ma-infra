resource "aws_instance" "ma_ec2" {
  #  count                  = 3
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "ZPI-EC2-${count.index}"
  }

  #  user_data = count.index == 0 ? local.first_manager_user_data : local.other_manager_user_data
  user_data =  <<-EOF
    #!/bin/bash

    sudo apt update

    echo "${var.gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
    echo "${var.ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa

    command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
    sudo usermod -aG docker ubuntu
    
    sudo docker swarm init

    printf "${var.secrets_spotify_client_id}" | sudo docker secret create spotify_client_id -
    printf "${var.secrets_spotify_client_secret}" | sudo docker secret create spotify_client_secret -
    printf "${var.secrets_database_user}" | sudo docker secret create db_user -
    printf "${var.secrets_database_password}" | sudo docker secret create db_password -
    sudo docker login registry.gitlab.com -u sunba23 -p ${var.secrets_gitlab_access_token}
EOF

}

#locals {
#  first_manager_user_data = <<-EOF
#    #!/bin/bash
#
#    sudo apt update
#
#    echo "${var.gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
#    echo "${var.ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
#    sudo chmod 600 ~/.ssh/id_rsa
#
#    command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
#    sudo usermod -aG docker ubuntu
#    
#    sudo docker swarm init
#
#    printf "${var.secrets_spotify_client_id}" | sudo docker secret create spotify_client_id -
#    printf "${var.secrets_spotify_client_secret}" | sudo docker secret create spotify_client_secret -
#    printf "${var.secrets_database_user}" | sudo docker secret create db_user -
#    printf "${var.secrets_database_password}" | sudo docker secret create db_password -
#    sudo docker login registry.gitlab.com -u sunba23 -p ${var.secrets_gitlab_access_token}
#EOF
#
#  other_manager_user_data = <<-EOF
#    #!bin/bash
#
#    sudo apt update
#
#    echo "${var.gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
#    echo "${var.ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
#    sudo chmod 600 ~/.ssh/id_rsa
#
#    command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
#    sudo usermod -aG docker ubuntu
#
#    sleep 15
#
#    FIRST_MANAGER_IP=${aws_instance.ma_ec2[0].private_ip}
#    echo "first manager ip is $FIRST_MANAGER_IP"
#
#    until JOIN_TOKEN=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa ubuntu@$FIRST_MANAGER_IP 'sudo docker swarm join-token manager -q') \
#      && sudo docker swarm join --token $JOIN_TOKEN $FIRST_MANAGER_IP:2377
#    do
#      echo "Retrying manager join in 10 seconds..."
#      sleep 10
#    done
#EOF
#}
