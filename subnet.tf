resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ecsvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true //it makes this a public subnet
  availability_zone       = "us-west-1a"

  tags = {
    Name = "Public"
  }
}
