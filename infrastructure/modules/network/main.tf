resource "aws_vpc" "ma_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Music Assistant VPC"
  }
}

# Public subnets in all 3 AZs
resource "aws_subnet" "ma_public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.ma_vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true  # Automatically assign public IPs to instances

  tags = {
    Name = "Music Assistant public subnet ${count.index + 1}"
  }
}

# Private subnets in all 3 AZs
resource "aws_subnet" "ma_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.ma_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Music Assistant private subnet ${count.index + 1}"
  }
}

# Internet Gateway for public internet access
resource "aws_internet_gateway" "ma_gateway" {
  vpc_id = aws_vpc.ma_vpc.id

  tags = {
    Name = "Music Assistant VPC internet gateway"
  }
}

# Route table for the public subnet
resource "aws_route_table" "ma_route_table" { 
  vpc_id = aws_vpc.ma_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ma_gateway.id
  }

  tags = {
    Name = "Music Assistant custom route table"
  }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "ma_public_rt_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.ma_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.ma_route_table.id
}

# Security Group for public subnet (open ports 80, 443, 22)
resource "aws_security_group" "ma_public_sg" {
  vpc_id = aws_vpc.ma_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere - TO BE CHANGED
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Music Assistant public security group"
  }
}

# Security Group for private subnet (allow traffic only from public subnet)
resource "aws_security_group" "ma_private_sg" {
  vpc_id = aws_vpc.ma_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all traffic
    security_groups = [aws_security_group.ma_public_sg.id]  # Only from public SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Music Assistant private security group"
  }
}
