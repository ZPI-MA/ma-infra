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
  # ami                    = "ami-0e04bcbe83a83792e"
  ami                    = "ami-0084a47cc718c111a"
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "Music Assistant EC2 instance"
  }

  user_data = templatefile("${path.module}/ec2_init.sh", {
    gitlab_ssh_public = var.gitlab_ssh_public
    ec2_ssh_private   = var.ec2_ssh_private
    duckdns_domain    = var.duckdns_domain
    duckdns_token     = var.duckdns_token
    secrets_ini       = data.template_file.secrets_ini.rendered
  })
}
