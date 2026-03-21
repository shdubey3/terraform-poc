resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true  # Public subnet

  tags = {
    Name        = "${var.environment}-subnet-1-public"
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = false  # Private subnet

  tags = {
    Name        = "${var.environment}-subnet-2-private"
    Environment = var.environment
    Tier        = "private"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_1.id  # Fix: NAT Gateway must be in public subnet

  tags = {
    Name        = "${var.environment}-nat-gw"
    Environment = var.environment
  }
}
