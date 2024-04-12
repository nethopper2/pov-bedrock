# Terraform EKS Cluster - Hub version

This Terraform configuration sets up an AWS EKS cluster along with necessary networking resources using the AWS provider. The setup includes defining providers, an EKS cluster, AWS authentication configurations, and outputs to assist with cluster management.

## Project Structure

- `main.tf`: This is the main file that contains the Terraform configuration for creating the AWS EKS cluster, VPC, and other necessary resources.
- `variables.tf`: Defines the variables used across the Terraform configuration to allow for customization and reusability.
- `outputs.tf`: Contains outputs that provide valuable information once Terraform has applied the configuration.
- `versions.tf`: Specifies the required Terraform version and required provider versions for this configuration.

## Setup and Initialization

To use this configuration:

1. **Install Terraform**: Ensure that you have Terraform installed on your machine. If not, download and install Terraform from [Terraform's website](https://www.terraform.io/downloads.html).

2. **Configure AWS CLI**: Make sure you have the AWS CLI installed and configured with the necessary access rights to create the resources defined in the Terraform configuration.

3. **Initialization**: Run `terraform init` in the root directory of this project. This command will initialize the project, download the required providers, and set up the Terraform state.

## Applying the Configuration

To create the resources defined in the Terraform configuration:

1. Run `terraform plan` to see the execution plan and review the resources that will be created or modified.

2. Execute `terraform apply` to apply the configuration. Terraform will prompt for confirmation before proceeding to create the resources.

## Managing the EKS Cluster

After applying the configuration, you can manage your EKS cluster using `kubectl`. The `configure_kubectl` output provides the command to configure `kubectl` with your new EKS cluster.

## Customization

You can customize the configuration by modifying the values in `variables.tf` or by passing different values when calling the module or using the `-var` or `-var-file` options with `terraform apply`.

## Cleaning Up

To destroy the resources created by this Terraform configuration, you can run `terraform destroy`. This command will prompt for confirmation before deleting the resources.
