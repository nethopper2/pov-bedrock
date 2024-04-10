# eks-calico
POC to provision EKS cluster with calico

We can try to use null_resources to automate the whole process.
```
resource "null_resource" "execute-cmd" {
  provisioner "local-exec" {
    command = "kubectl ..."
  }
}
```

## References
1. [install-eks-with-calico-networking](https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks#install-eks-with-calico-networking)
2. [terraform-aws-eks-blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
3. [eks module to check](https://github.com/akw-devsecops/terraform-aws-eks/tree/v2.6.11)