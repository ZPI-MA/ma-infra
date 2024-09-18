output "instance_public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.tic_tac_toe.public_ip
}