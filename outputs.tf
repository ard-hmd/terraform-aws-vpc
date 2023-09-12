# # Outputs related to networking and infrastructure components

# # VPC ID
# output "vpc_id" {
#     value = vpc.vpc_id
# }

# # IDs of public subnets
# output "public_subnet_ids" {
#     value = var.public_subnets_cidr
# }

# # IDs of private subnets
# output "private_subnet_ids" {
#     value = var.public_subnets_cidr
# }

# # IDs of NAT Gateways
# output "nat_gateway_ids" {
#   value = gateways.nat_gateway_ids
# }

# # IDs of AWS Internet Gateways
# output "aws_internet_gateway_ids" {
#   value = gateways.aws_internet_gateway_ids
# }

# # IDs of private route tables
# output "private_route_table_ids" {
#   value = route_tables.private_route_table_ids
# }

# # ID of the public route table
# output "public_route_table_id" {
#   value = route_tables.public_route_table_id
# }

# # Outputs related to Security Groups

# # ID of the RDS security group
# output "sg_rds_id" {
#   description = "The ID of the RDS security group"
#   value       = sg_rds.sg_rds_id
# }

# # Name of the RDS subnet group
# output "main_rds_subnet_group_name" {
#   description = "The name of the RDS subnet group from the module."
#   value       = subnets.rds_subnet_group_name
# }

# # Subnet IDs in the RDS subnet group
# output "main_rds_subnet_group_subnet_ids" {
#   description = "The list of subnet IDs in the RDS subnet group from the module."
#   value       = subnets.rds_subnet_group_subnet_ids
# }

# # Tags of the RDS subnet group
# output "main_rds_subnet_group_tags" {
#   description = "The tags for the RDS subnet group from the module."
#   value       = subnets.rds_subnet_group_tags
# }
