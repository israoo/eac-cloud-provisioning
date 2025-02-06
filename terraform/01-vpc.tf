resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet.cidr_block
  availability_zone = var.subnet.availability_zone

  tags = {
    Name = "Terraform-Public-Subnet"
  }

  depends_on = [aws_vpc.main_vpc]
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Terraform-IGW"
  }

  depends_on = [aws_vpc.main_vpc]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Terraform-Public-RT"
  }

  depends_on = [
    aws_vpc.main_vpc,
    aws_internet_gateway.main_igw
  ]
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

  depends_on = [
    aws_subnet.public_subnet,
    aws_route_table.public_rt
  ]
}
