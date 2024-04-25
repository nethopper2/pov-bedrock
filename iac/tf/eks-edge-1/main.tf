provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws-cli-profile]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws-cli-profile]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster-name
  cluster_version                = var.k8s-version
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # calico-apiserver
    ingress_cluster_5443_webhook = {
      description                   = "Cluster API to node 5443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 5443
      to_port                       = 5443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    # DNS TCP
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }

    ingress_self_coredns_tcp_2 = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 9153
      to_port     = 9153
      type        = "ingress"
      self        = true
    }


    # DNS UDP
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS UDP"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
  }
}

################################################################################
# Calico Setup
################################################################################

resource "null_resource" "get_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.aws-cli-profile}"
  }

  depends_on = [module.eks]

}

resource "null_resource" "disable_vpc_networking" {
  provisioner "local-exec" {
    command = "kubectl delete daemonset -n kube-system aws-node"
  }

  depends_on = [null_resource.get_kubeconfig]
}

resource "null_resource" "remove_coredns" {
  provisioner "local-exec" {
    command = "kubectl delete deployment -n kube-system coredns"
  }

  depends_on = [null_resource.get_kubeconfig]
}

resource "helm_release" "tigera_operator" {
  name       = "tigera-operator"
  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  namespace  = "kube-system"
  version    = "v3.27.3"
  wait       = false

  set {
    name  = "installation.kubernetesProvider"
    value = "EKS"
  }

  depends_on = [null_resource.disable_vpc_networking]
}

resource "null_resource" "patch_installation_cni" {
  provisioner "local-exec" {
    command = "kubectl patch installation default --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/cni\", \"value\": {\"type\":\"Calico\"} }]'"
  }

  depends_on = [helm_release.tigera_operator]
}

module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 20.0"

  name            = "managed-ng"
  cluster_name    = var.cluster-name
  cluster_version = var.k8s-version

  subnet_ids = module.vpc.private_subnets

  cluster_primary_security_group_id = module.eks.cluster_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
  cluster_service_cidr              = module.eks.cluster_service_cidr

  instance_types = [var.instance-type]

  min_size     = 1
  max_size     = 1
  desired_size = 1

  enable_bootstrap_user_data = false

  pre_bootstrap_user_data = <<-EOT
    #!/bin/bash
    LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
    REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=100/g')"
    sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
    sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
  EOT

  depends_on = [helm_release.tigera_operator]
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.14"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_delay_dependencies = [module.eks_managed_node_group.node_group_arn]

  eks_addons = {
    coredns    = {}
    kube-proxy = {}
  }

  enable_velero = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster-name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
