output "ec2_public_ip" {
  value       = module.ec2.instance_public_ip
  description = "Public IP address of the EC2 instance"
}
