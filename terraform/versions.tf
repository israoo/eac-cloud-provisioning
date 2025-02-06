terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.82.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 14.0.6"
    }
  }
}
