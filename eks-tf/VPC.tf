# Create a VPC with a specified CIDR block
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # CIDR block for the VPC

  # Enable DNS support and hostnames for the VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Tags for identifying the VPC
  tags = {
    Name = "main"
  }
}

