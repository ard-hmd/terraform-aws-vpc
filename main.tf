# AWS VPC
resource "aws_vpc" "custom_vpc" {
  # Définition du bloc CIDR pour le VPC
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Création des sous-réseaux publics AWS
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

# Création des sous-réseaux privés AWS
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

# Création du groupe de sous-réseaux RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "Rds Subnet Group"
  }
}

# Création des tables de routage privées pour chaque sous-réseau privé
resource "aws_route_table" "private" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table-${element(var.azs, count.index)}"
    Environment = var.environment
  }
}

# Création d'une table de routage public pour les sous-réseaux publics
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

# Création d'une passerelle Internet AWS
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Création d'une route par défaut vers la passerelle Internet pour les sous-réseaux publics
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Création des passerelles NAT AWS
resource "aws_nat_gateway" "nat" {
  count          = length(var.public_subnets_cidr)
  allocation_id  = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id      = aws_subnet.public_subnet[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gateway-${element(var.azs, count.index)}"
    Environment = var.environment
  }
}

# Création d'une route par défaut vers la passerelle NAT pour les sous-réseaux privés
resource "aws_route" "private_nat_gateway" {
  count                 = length(var.private_subnets_cidr)
  route_table_id        = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.nat[count.index].id
}

# Association des sous-réseaux publics avec la table de routage public
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Association des sous-réseaux privés avec leurs tables de routage privées respectives
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Création des IPs élastiques AWS pour les passerelles NAT
resource "aws_eip" "nat_eip" {
  count      = length(var.public_subnets_cidr)
  vpc        = true
  depends_on = [aws_internet_gateway.ig]

  tags = {
    Name        = "${var.environment}-nat-eip-${element(var.azs, count.index)}"
    Environment = var.environment
  }
}
