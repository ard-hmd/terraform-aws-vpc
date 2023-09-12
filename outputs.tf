output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.custom_vpc.id
}

output "public_subnets_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnets_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private_subnet.*.id
}

output "rds_subnet_group_name" {
  description = "The name of the RDS subnet group."
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "public_route_table_ids" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables."
  value       = aws_route_table.private.*.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway."
  value       = aws_internet_gateway.ig.id
}

output "nat_gateways_ids" {
  description = "The IDs of the NAT gateways."
  value       = aws_nat_gateway.nat.*.id
}

output "elastic_ips" {
  description = "The Elastic IPs associated with the NAT gateways."
  value       = aws_eip.nat_eip.*.public_ip
}

