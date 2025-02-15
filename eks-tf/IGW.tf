# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # Associate the IGW with the VPC

  # Tags for identifying the Internet Gateway
  tags = {
    Name = "igw"
  }
}
