# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  vpc = true # Allocate the EIP in the VPC

  tags = {
    Name = "nat"
  }
}

# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id          # Associate the NAT Gateway with the EIP
  subnet_id     = aws_subnet.public_us_west_2a.id # Place the NAT Gateway in the public subnet

  tags = {
    Name = "nat"
  }

  # Ensure the Internet Gateway is created before the NAT Gateway
  depends_on = [aws_internet_gateway.igw]
}
