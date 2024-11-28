output "first_instance_public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.first_manager.public_ip
}

output "other_instances_public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.other_managers.*.public_ip
}
