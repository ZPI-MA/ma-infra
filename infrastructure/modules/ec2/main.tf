resource "aws_instance" "first_manager" {
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "ZPI-EC2-Manager-1"
  }

  user_data = local.first_manager_user_data
}

resource "aws_instance" "other_managers" {
  count                  = 2
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name              = "ec2-ssh"
  
  tags = {
    Name = "ZPI-EC2-Manager-${count.index + 2}"
  }

  depends_on = [aws_instance.first_manager]

  user_data = templatefile("${path.module}/other_manager_init.tpl", {
    first_manager_ip     = aws_instance.first_manager.private_ip
    gitlab_ssh_public    = var.gitlab_ssh_public
    ec2_ssh_private      = var.ec2_ssh_private
  })
}

locals {
  first_manager_user_data = <<-EOF
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
