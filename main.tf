# =============================
# VPC and Associated Resources
# =============================

# Create a custom VPC in AWS
resource "aws_vpc" "custom_vpc" {
  # Define the CIDR block for the VPC
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Create public subnets within the VPC
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(var.azs, count.index)}-public-subnet"
    Environment = var.environment
  }
}

# Create private subnets within the VPC
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${element(var.azs, count.index)}-private-subnet"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"  # Name of the RDS subnet group
  subnet_ids = aws_subnet.private_subnet.*.id  # Use the IDs of private subnets for RDS instances

  tags = {
    Name = "Rds Subnet Group"  # Assign a tag to the subnet group
  }
}

# Create private route tables for each private subnet
resource "aws_route_table" "private" {
  count = length(var.private_subnets_cidr)  # Creating multiple resources based on the count of private subnets
  vpc_id = aws_vpc.custom_vpc.id  # Associating the route table with the VPC

  tags = {
    Name        = "${var.environment}-private-route-table-${element(var.azs, count.index)}"  # Naming the route table
    Environment = var.environment
  }
}

# Create a public route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id  # Associating the route table with the VPC

  tags = {
    Name        = "${var.environment}-public-route-table"  # Naming the route table
    Environment = var.environment
  }
}



# =============================
# Internet Access Resources
# =============================

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Create NAT gateways for the public subnets
resource "aws_nat_gateway" "nat" {
  count          = length(var.public_subnets_cidr)
  allocation_id  = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id      = aws_subnet.public_subnet[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gateway-${element(var.azs, count.index)}"
    Environment = var.environment
  }
}

# Create a default route pointing to the internet gateway for public subnets
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Create a default route pointing to the NAT gateway for private subnets
resource "aws_route" "private_nat_gateway" {
  count                 = length(var.private_subnets_cidr)
  route_table_id        = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.nat[count.index].id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with their respective private route tables
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create Elastic IPs for the NAT gateways
resource "aws_eip" "nat_eip" {
  count      = length(var.public_subnets_cidr)
  domain        = true
  depends_on = [aws_internet_gateway.ig]
  
  tags = {
    Name        = "${var.environment}-nat-eip-${element(var.azs, count.index)}"
    Environment = var.environment
  }
}

