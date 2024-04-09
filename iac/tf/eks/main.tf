# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "aws" {
  region = var.region

  # in-cluster tf (e.g. crossplane)
  #shared_credentials_file = "aws-creds.ini"

  # local tf
  shared_credentials_files = ["/home/ddonahue/.aws/credentials"]
}

# s3 backend
terraform {
  backend "s3" {
    bucket = "pov-bedrock-tfstate"
    key    = "tfstate/key"
    region = "us-east-2"
  }
}

# local backend
#terraform {
#  backend "local" {
#  }
#}

# in-cluster backend
#provider "kubernetes" {
#  host                   = module.eks.cluster_endpoint
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#}
    
#Modules _must_ use remote state. The provider does not persist state.
#terraform {
#  backend "kubernetes" {
#    secret_suffix     = "providerconfig-default"
#    namespace         = "nethopper"
#    in_cluster_config = true
#  }
#}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "bedrock-${var.cluster-name-suffix}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
