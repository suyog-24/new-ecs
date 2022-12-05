
resource "aws_vpc" "ecsvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecsvpc"
  }
}

