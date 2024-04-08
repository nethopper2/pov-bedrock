variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster-name-suffix" {
  description = "Cluster name suffix"
  type        = string
  default     = "eks"
}

variable "k8s-version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

