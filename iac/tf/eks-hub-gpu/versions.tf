terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
  backend "s3" {
    bucket = "pov-bedrock-tfstate"
    region = "us-east-2"
    key    = "eks-hub-gpu/terraform.tfstate"
  }
}
