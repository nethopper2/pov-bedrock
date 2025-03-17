variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "cluster-name" {
  description = "Cluster name"
  type        = string
  default     = "cluster-name"
}

variable "k8s-version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "aws-cli-profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
} 

variable "instance-type" {
  description = "Instance type"
  type        = string
  default     = "g4dn.2xlarge"
}

variable "vpc_cidr" {
  description = "value of the VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_type" {
  description = "AMI type"
  type        = string
  default     = "AL2_x86_64_GPU"
}