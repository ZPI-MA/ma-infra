data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "first_manager" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = {
    Name = "ZPI-EC2-Manager-1"
  }

  user_data = templatefile("${path.module}/first_manager_init.tpl", {
    gitlab_ssh_public    = var.gitlab_ssh_public
    ec2_ssh_private      = var.ec2_ssh_private
  })
  user_data = templatefile("${path.module}/first_manager_init.tpl", {
    region                        = data.aws_region.current.name
    gitlab_ssh_public             = var.gitlab_ssh_public
    ec2_ssh_private               = var.ec2_ssh_private
    secrets_spotify_client_id     = var.secrets_spotify_client_id
    secrets_spotify_client_secret = var.secrets_spotify_client_secret
    secrets_database_user         = var.secrets_database_user
    secrets_database_password     = var.secrets_database_password
    gitlab_access_token           = var.gitlab_access_token
  })
}

resource "aws_instance" "other_managers" {
  count                  = 2
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = "ec2-ssh"
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  
  tags = {
    Name = "ZPI-EC2-Manager-${count.index + 2}"
  }

  depends_on = [aws_instance.first_manager]

  user_data = templatefile("${path.module}/other_manager_init.tpl", {
    region               = data.aws_region.current.name
    gitlab_ssh_public    = var.gitlab_ssh_public
    ec2_ssh_private      = var.ec2_ssh_private
  })
}

# role for the swarm ec2 instances
resource "aws_iam_role" "ec2_ssm_role" {
  name = "docker-swarm-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# allow ec2 to use systems manager
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# allow ec2 to use parameter store
resource "aws_iam_role_policy" "parameter_store_policy" {
  name = "parameter-store-access"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/docker/swarm/*"
      }
    ]
  })
}

# Profile to attach the role to EC2 instances
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "docker-swarm-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
