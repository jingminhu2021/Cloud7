# # VPC
# resource "aws_vpc" "main-vpc" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = {
#     Name = "main-vpc"
#   }
# }

# # Internet Gateway
# resource "aws_internet_gateway" "main-igw" {
#   vpc_id = aws_vpc.main-vpc.id
#   tags = {
#     Name = "main-igw"
#   }
# }

# # Route Table
# resource "aws_route_table" "main-rt" {
#   vpc_id = aws_vpc.main-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main-igw.id
#   }

#   tags = {
#     Name = "main-rt"
#   }
# }

# # Subnet
# resource "aws_subnet" "public-subnet-1" {
#   vpc_id            = aws_vpc.main-vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "ap-southeast-1a"

#   tags = {
#     Name = "public-subnet-1"
#   }
# }

# resource "aws_subnet" "private-subnet-1" {
#   vpc_id     = aws_vpc.main-vpc.id
#   cidr_block = "10.0.10.0/24"

#   tags = {
#     Name = "private-subnet-1"
#   }
# }

# # Associate Route Table with Subnet
# resource "aws_route_table_association" "public-subnet-1" {
#   subnet_id      = aws_subnet.public-subnet-1.id
#   route_table_id = aws_route_table.main-rt.id
# }

# resource "aws_route_table_association" "private-subnet-1" {
#   subnet_id      = aws_subnet.private-subnet-1.id
#   route_table_id = aws_route_table.main-rt.id
# }

# # Security Group
# resource "aws_security_group" "allow_web_traffic" {
#   name        = "allow_web_traffic"
#   description = "Allow Web inbound traffic"
#   vpc_id      = aws_vpc.main-vpc.id

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "Outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_web_traffic"
#   }
# }
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "tf-vpc"
  cidr   = var.vpc_cidr
  azs    = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1)
  ]
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 2),
    cidrsubnet(var.vpc_cidr, 8, 3)
  ]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = var.tags
}
