variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
  })
}

variable "subnet" {
  description = "Subnet configuration"
  type = object({
    cidr_block        = string
    availability_zone = string
  })
}

variable "ec2" {
  description = "EC2 instance configuration"
  type = object({
    ami           = string
    instance_type = string
  })
}
