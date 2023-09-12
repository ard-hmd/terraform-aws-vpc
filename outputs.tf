# Output the ID of the created VPC
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.custom_vpc.id
}

# Output the IDs of the public subnets created within the VPC
output "public_subnets_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public_subnet.*.id
}

# Output the IDs of the private subnets created within the VPC
output "private_subnets_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private_subnet.*.id
}

# Output the name of the RDS subnet group created
output "rds_subnet_group_name" {
  description = "The name of the RDS subnet group."
  value       = aws_db_subnet_group.rds_subnet_group.name
}

# Output the ID of the public route table associated with the VPC
output "public_route_table_ids" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

# Output the IDs of the private route tables associated with the VPC
output "private_route_table_ids" {
  description = "The IDs of the private route tables."
  value       = aws_route_table.private.*.id
}

# Output the ID of the internet gateway attached to the VPC
output "internet_gateway_id" {
  description = "The ID of the internet gateway."
  value       = aws_internet_gateway.ig.id
}

# Output the IDs of the NAT gateways created within the VPC
output "nat_gateways_ids" {
  description = "The IDs of the NAT gateways."
  value       = aws_nat_gateway.nat.*.id
}

# Output the Elastic IPs associated with the NAT gateways in the VPC
output "elastic_ips" {
  description = "The Elastic IPs associated with the NAT gateways."
  value       = aws_eip.nat_eip.*.public_ip
}
