# Create a private route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route for internet access via the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

# Create a public route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route for internet access via the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_us_west_2a" {
  subnet_id      = aws_subnet.private_us_west_2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_us_west_2b" {
  subnet_id      = aws_subnet.private_us_west_2b.id
  route_table_id = aws_route_table.private.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_us_west_2a" {
  subnet_id      = aws_subnet.public_us_west_2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_us_west_2b" {
  subnet_id      = aws_subnet.public_us_west_2b.id
  route_table_id = aws_route_table.public.id
}
