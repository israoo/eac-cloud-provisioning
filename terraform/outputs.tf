output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.main_instance.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.main_instance.public_ip
}

output "ssh_private_key_path" {
  description = "The path to the SSH private key"
  value       = local_file.private_key.filename
}
