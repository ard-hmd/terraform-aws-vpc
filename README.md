# Terraform AWS VPC Module

This Terraform module provides a way to create a fully-configured AWS VPC environment. It sets up a VPC with both public and private subnets, ensuring secure and scalable infrastructure deployment. The module is designed to be flexible, allowing users to customize the VPC according to their requirements.

## Features

- **VPC Creation**: Sets up a VPC with a custom CIDR block, ensuring a unique and isolated network space.
- **Subnet Configuration**: Creates public and private subnets, allowing for a separation of resources based on their exposure to the internet.
- **Gateway Setup**: Configures Internet and NAT gateways, ensuring connectivity for resources and secure internet access for private resources.
- **Route Tables**: Generates appropriate route tables for each subnet, directing traffic correctly.
- **Outputs**: Provides essential IDs and values for further AWS configurations and resource linking.

## Usage

To integrate this module into your Terraform configuration, use the following example. Adjust the variables as needed to fit your requirements:

```hcl
module "aws_vpc" {
  source                  = "github.com/ard-hmd/terraform-aws-vpc"
  region                  = var.aws_region
  vpc_cidr                = var.vpc_cidr
  environment             = var.environment
  azs                     = var.azs
  public_subnets_cidr     = var.public_subnets_cidr
  private_subnets_cidr    = var.private_subnets_cidr
}
```

## Variables

Here are the primary variables you might want to adjust:

- `var.aws_region`: Specifies the AWS region where the VPC and related resources will be created. Default is set to `eu-west-3`.
- `var.vpc_cidr`: Defines the CIDR block for the VPC, determining the range of IP addresses for the network. Default is `10.0.0.0/16`.
- For a complete list of available variables and their descriptions, please refer to the [vars.tf](./vars.tf) file.

## Outputs

After applying the module, you'll receive several outputs that can be used in other parts of your Terraform configuration:

- `vpc_id`: The unique ID of the created VPC.
- `public_subnets_ids`: A list of IDs for the public subnets, useful for deploying public-facing resources.
- For a complete list of outputs and their descriptions, please refer to the [outputs.tf](./outputs.tf) file.

