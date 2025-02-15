# Create private subnets in different availability zones
resource "aws_subnet" "private_us_west_2a" {
  vpc_id            = aws_vpc.main.id       # Associate subnet with the VPC
  cidr_block        = "10.0.0.0/19"         # CIDR block for the subnet
  availability_zone = "us-west-2a"          # Availability zone for the subnet

  # Tags for identifying the subnet and enabling internal ELB
  tags = {
    "Name"                            = "private-us-west-2a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "private_us_west_2b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-west-2b"

  tags = {
    "Name"                            = "private-us-west-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

# Create public subnets in different availability zones
resource "aws_subnet" "public_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true # Enable auto-assignment of public IPs

  tags = {
    "Name"                       = "public-us-west-2a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_subnet" "public_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-west-2b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
