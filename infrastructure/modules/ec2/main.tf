data "template_file" "secrets_ini" {
  template = file("${path.module}/secrets.ini.tpl")
  
  vars = {
    spotify_client_id     = var.secrets_spotify_client_id
    spotify_client_secret = var.secrets_spotify_client_secret
    database_user         = var.secrets_database_user
    database_password     = var.secrets_database_password
  }
}

resource "aws_instance" "ma_ec2" {
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "Music Assistant EC2 instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    echo "${var.gitlab_ssh_public}" | sudo tee -a ~/.ssh/known_hosts
    command -v docker >/dev/null 2>&1 || { echo "Installing docker..." && curl -fsSL https://get.docker.com | sudo bash; }
    echo "${var.ec2_ssh_private}" | sudo tee -a ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa
    sudo mkdir /run/secrets

    # Create the .ini file
    cat << ~'INIFILE' | sudo tee /run/secrets/secrets.ini
      ${data.template_file.secrets_ini.rendered}
    INIFILE

    sudo chmod 600 /run/secrets/config.ini
  EOF
}
