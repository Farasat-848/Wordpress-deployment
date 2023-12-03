

# Creating Subnet here 

resource "aws_subnet" "my_public_subnet" {

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_block

  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet"
  }
  
}
