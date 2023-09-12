# AWS VPC
resource "aws_vpc" "vpc" {
  # Define the CIDR block for the VPC
  cidr_block           = aws_vpc.vpc_cidr

  # Enable DNS hostnames for instances in the VPC
  enable_dns_hostnames = true

  # Enable DNS support for the VPC
  enable_dns_support   = true

  # Add tags to the VPC for identification
  tags = {
    Name        = "${aws_vpc.environment}-vpc"
    Environment = aws_vpc.environment
  }
}

# Create AWS public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(aws_vpc.public_subnets_cidr)  # Create multiple subnets based on the count of provided CIDR blocks
  vpc_id                  = aws_vpc.vpc_id  # Associate the subnets with the specified VPC
  cidr_block              = element(aws_vpc.public_subnets_cidr, count.index)  # Use the CIDR block from the list based on the count index
  availability_zone       = element(aws_vpc.availability_zones, count.index)  # Use the availability zone from the list based on the count index
  map_public_ip_on_launch = true  # Enable automatic public IP assignment for instances launched in this subnet

  tags = {
    Name        = "${aws_vpc.environment}-${element(aws_vpc.availability_zones, count.index)}-public-subnet"  # Create a unique name for each subnet
    Environment = "${aws_vpc.environment}"  # Assign the specified environment tag
  }
}

# Create AWS private subnets
resource "aws_subnet" "private_subnet" {
  count                   = length(aws_vpc.private_subnets_cidr)  # Create multiple subnets based on the count of provided CIDR blocks
  vpc_id                  = aws_vpc.vpc_id  # Associate the subnets with the specified VPC
  cidr_block              = element(aws_vpc.private_subnets_cidr, count.index)  # Use the CIDR block from the list based on the count index
  availability_zone       = element(aws_vpc.availability_zones, count.index)  # Use the availability zone from the list based on the count index
  map_public_ip_on_launch = false  # Do not assign automatic public IP addresses

  tags = {
    Name        = "${aws_vpc.environment}-${element(aws_vpc.availability_zones, count.index)}-private-subnet"  # Create a unique name for each subnet
    Environment = "${aws_vpc.environment}"  # Assign the specified environment tag
  }
}

# Create RDS subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"  # Name of the RDS subnet group
  subnet_ids = aws_subnet.private_subnet.*.id  # Use the IDs of private subnets for RDS instances

  tags = {
    Name = "Rds Subnet Group"  # Assign a tag to the subnet group
  }
}

# Create private route tables for each private subnet
resource "aws_route_table" "private" {
  count = length(aws_vpc.private_subnets_cidr)  # Creating multiple resources based on the count of private subnets
  vpc_id = aws_vpc.vpc_id  # Associating the route table with the VPC

  tags = {
    Name        = "${aws_vpc.environment}-private-route-table-${element(aws_vpc.availability_zones, count.index)}"  # Naming the route table
    Environment = aws_vpc.environment
  }
}

# Create a public route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_id  # Associating the route table with the VPC

  tags = {
    Name        = "${aws_vpc.environment}-public-route-table"  # Naming the route table
    Environment = aws_vpc.environment
  }
}

# Create a default route to the Internet Gateway for public subnets
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id  # Associating the route with the public route table
  destination_cidr_block = "0.0.0.0/0"  # Destination CIDR block for the default route
  gateway_id             = aws_vpc.internet_gateway_id  # Target Internet Gateway
}

# Create a default route to NAT Gateway for private subnets
resource "aws_route" "private_nat_gateway" {
  count                 = length(aws_vpc.private_subnets_cidr)  # Creating multiple routes based on the count of private subnets
  route_table_id        = element(aws_route_table.private.*.id, count.index)  # Associating the route with the private route table
  destination_cidr_block = "0.0.0.0/0"  # Destination CIDR block for the default route
  nat_gateway_id        = element(aws_vpc.nat_gateway_ids, count.index)  # Target NAT Gateway
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_vpc.public_subnets_cidr)  # Associating public subnets with public route table
  subnet_id      = element(aws_vpc.public_subnet_ids, count.index)  # Subnet to associate
  route_table_id = aws_route_table.public.id  # Route table to associate with
}

# Associate private subnets with their respective private route tables
resource "aws_route_table_association" "private" {
  count          = length(aws_vpc.private_subnets_cidr)  # Associating private subnets with private route tables
  subnet_id      = element(aws_vpc.private_subnet_ids, count.index)  # Subnet to associate
  route_table_id = element(aws_route_table.private.*.id, count.index)  # Route table to associate with
}


# Create an AWS Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc_id  # Attach the Internet Gateway to the specified VPC

  tags = {
    "Name"        = "${aws_vpc.environment}-igw"  # Set a meaningful name for the Internet Gateway
    "Environment" = aws_vpc.environment
  }
}

# Create AWS Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count      = length(aws_vpc.public_subnets_cidr)  # Create an EIP for each public subnet
  vpc        = true
  depends_on = [aws_internet_gateway.ig]  # Ensure Internet Gateway is created first

  tags = {
    Name        = "${aws_vpc.environment}-nat-eip-${element(aws_vpc.availability_zones, count.index)}"
    Environment = aws_vpc.environment
  }
}

# Create AWS NAT Gateways
resource "aws_nat_gateway" "nat" {
  count          = length(aws_vpc.public_subnets_cidr)  # Create a NAT Gateway for each public subnet
  allocation_id  = element(aws_eip.nat_eip.*.id, count.index)  # Use the EIP ID as the allocation ID
  subnet_id      = element(aws_vpc.public_subnet_ids, count.index)  # Use the corresponding public subnet

  tags = {
    Name        = "${aws_vpc.environment}-nat-gateway-${element(aws_vpc.availability_zones, count.index)}"
    Environment = aws_vpc.environment
  }
}

