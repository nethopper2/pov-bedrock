# Terraform EKS Cluster Provisioning

This repository contains Terraform code for provisioning Amazon EKS (Elastic Kubernetes Service) clusters. It's designed to support various EKS cluster configurations, including hub and edge clusters in a potential nethopper network setup.

## Directory Structure

- `eks`: Contains an example setup for an EKS cluster. Please note that this example uses an older version of EKS and may need updates before use.
- `eks-hub`: Configuration files for setting up an EKS cluster intended to serve as a hub in a nethopper network configuration.
- `eks-edge`: Configuration files for establishing an EKS cluster designed to function as an edge cluster in a nethopper network setup.

## Notes

### Automation using null_resource

To streamline the process, we consider leveraging Terraform's `null_resource` to execute local commands. An example use case is automating `kubectl` commands post-cluster creation:

```hcl
resource "null_resource" "execute-cmd" {
  provisioner "local-exec" {
    command = "kubectl apply -f some-configuration-file.yaml"
  }
}
```

## References
1. [install-eks-with-calico-networking](https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks#install-eks-with-calico-networking)
2. [terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
3. [eks module to check](https://github.com/akw-devsecops/terraform-aws-eks/tree/v2.6.11)