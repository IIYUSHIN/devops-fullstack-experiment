# ============================================
# Terraform — VPC (Virtual Private Cloud)
# ============================================
# A VPC is your own isolated network inside AWS.
# Think of it as your private data center in the cloud.
#
# Architecture:
#   VPC (10.0.0.0/16) — the whole network
#     ├── Public Subnet 1 (10.0.1.0/24) — Availability Zone A
#     ├── Public Subnet 2 (10.0.2.0/24) — Availability Zone B
#     ├── Internet Gateway — connects VPC to the internet
#     └── Route Table — tells traffic where to go

# ── Get Available Availability Zones ──
# Dynamically fetches the AZs in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

# ── VPC ──
# The main network container — all resources live inside this
# CIDR 10.0.0.0/16 = 65,536 IP addresses available
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# ── Public Subnets ──
# Two subnets in different Availability Zones for high availability
# If one AZ goes down, the app still runs in the other

# Subnet 1 — Availability Zone A
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-1"
  }
}

# Subnet 2 — Availability Zone B
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-subnet-2"
  }
}

# ── Internet Gateway ──
# Connects the VPC to the public internet
# Without this, nothing inside the VPC can reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# ── Route Table ──
# Defines routing rules: "send all internet-bound traffic through the IGW"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# ── Associate Subnets with Route Table ──
# Links each subnet to the route table so they can access the internet
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
