resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecsvpc.id

  tags = {
    Name = "IGW"
  }
}