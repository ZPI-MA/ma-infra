output "vpc_id" {
  value = aws_vpc.ma_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.ma_public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.ma_private_subnets[*].id
}

output "public_sg_id" {
  value = aws_security_group.ma_public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.ma_private_sg.id
}
