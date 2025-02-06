aws_region = "us-east-1"

vpc = {
  cidr_block = "10.0.0.0/16"
}

subnet = {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

ec2 = {
  ami           = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
}
