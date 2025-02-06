resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "Terraform-Generic-Key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "Terraform-Generic-Key"
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/../ansible/terraform_generated_key.pem"
  file_permission = "0600"
}

resource "aws_security_group" "main_instance_sg" {
  name        = "Terraform-Instance-SG"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    description = "Allow all traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Instance-SG"
  }

  depends_on = [aws_vpc.main_vpc]
}

resource "aws_instance" "main_instance" {
  ami                    = var.ec2.ami
  instance_type          = var.ec2.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  tags = {
    Name = "Terraform-EC2"
  }

  depends_on = [
    aws_subnet.public_subnet,
    aws_security_group.main_instance_sg,
    aws_key_pair.generated_key
  ]
}

resource "local_file" "ansible_vars" {
  content         = <<EOF
---
ec2_instance_public_ip: ${aws_instance.main_instance.public_ip}
ec2_instance_user: ec2-user
EOF
  filename        = "${path.module}/../ansible/vars/ec2-instance.yml"
  file_permission = "0644"
}
