# Set the default AWS region for the resources
variable "aws_region" {
  default = "eu-west-3"
  description = "Default AWS region where resources will be created."
}

# Define the availability zones for the resources
variable "azs" {
  default = ["eu-west-3a", "eu-west-3b"]
  description = "List of availability zones within the specified AWS region."
}

# Set the default environment label for the resources
variable "environment" {
  default = "prod"
  description = "Environment label to be used for naming and tagging resources."
}

# Set the CIDR block for the VPC
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the Virtual Private Cloud (VPC)."
}

# Define the CIDR blocks for public subnets
variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["10.0.0.0/20", "10.0.128.0/20"]
  description = "List of CIDR blocks for the public subnets within the VPC."
}

# Define the CIDR blocks for private subnets
variable "private_subnets_cidr" {
  type        = list(any)
  default     = ["10.0.16.0/20", "10.0.144.0/20"]
  description = "List of CIDR blocks for the private subnets within the VPC."
}
