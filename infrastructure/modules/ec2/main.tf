resource "aws_instance" "ma_ec2" {
  count                  = 3
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "ZPI-EC2-${count.index}"
  }

  user_data = <<-EOF
    #!/bin/bash

    sudo apt update

    echo "${var.gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
    echo "${var.ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa

    command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
    printf "${var.secrets_spotify_client_id}" | docker secret create spotify-client-id -
    printf "${var.secrets_spotify_client_secret}" | docker secret create spotify-client-secret -
    printf "${var.secrets_database_user}" | docker secret create db-user -
    printf "${var.secrets_database_password}" | docker secret create db-password -
    docker login registry.gitlab.com -u sunba23 -p ${var.secrets_gitlab_access_token}
    docker swarm init
  EOF
}
