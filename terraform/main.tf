terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# VPC
# ============================================================
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "ecommerce-vpc"
    Project = "E-CommerceStore"
  }
}

# ============================================================
# Internet Gateway
# ============================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  tags = {
    Name    = "ecommerce-igw"
    Project = "E-CommerceStore"
  }
}

# ============================================================
# Public Subnet
# ============================================================
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ecommerce_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ecommerce-public-subnet"
    Project = "E-CommerceStore"
  }
}

# ============================================================
# Route Table
# ============================================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "ecommerce-public-rt"
    Project = "E-CommerceStore"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ============================================================
# Security Group
# ============================================================
resource "aws_security_group" "ecommerce_sg" {
  name        = "ecommerce-sg"
  description = "Allow HTTP (80), backend services (3001-3004), and SSH (22)"
  vpc_id      = aws_vpc.ecommerce_vpc.id

  # Frontend HTTP
  ingress {
    description = "HTTP Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend microservices ports
  ingress {
    description = "Backend Microservices"
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ecommerce-sg"
    Project = "E-CommerceStore"
  }
}

# ============================================================
# Latest Ubuntu 22.04 AMI
# ============================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================
# EC2 Instance
# ============================================================
resource "aws_instance" "ecommerce_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ecommerce_sg.id]

  # Bootstrap script — installs Docker and starts all containers
  user_data = templatefile("${path.module}/user_data.sh", {
    dockerhub_username = var.dockerhub_username
    mongodb_uri        = var.mongodb_uri
    jwt_secret         = var.jwt_secret
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "ecommerce-server"
    Project = "E-CommerceStore"
  }
}
