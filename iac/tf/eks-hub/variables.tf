variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster-name" {
  description = "Cluster name"
  type        = string
  default     = "eks-cluster"
}

variable "k8s-version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "aws-cli-profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}