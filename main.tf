#creating the VPC for the infrastructure
resource "aws_vpc" "HESTIO_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "HESTIO_VPC"
  }
}
#Creating Public Subnet
resource "aws_subnet" "HESTIO_PB_SN" {
  vpc_id     = aws_vpc.HESTIO_VPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "HESTIO_PB_SN"
  }
}
#Creating Private Subnet
resource "aws_subnet" "HESTIO_PR_SN" {
  vpc_id     = aws_vpc.HESTIO_VPC.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "HESTIO_PR_SN"
  }
}
#Creating Internet Gateway
resource "aws_internet_gateway" "HESTIO_IGW" {
  vpc_id = aws_vpc.HESTIO_VPC.id
  tags = {
    Name = "HESTIO_IGW"
  }
}
#Creating Elastic IP for the NAT Gateway
resource "aws_eip" "HESTIO_EIP1" {
  vpc = true
  tags = {
    Name = "HESTIO_EIP1"
  }
}
#Creating  NAT Gateway
resource "aws_nat_gateway" "HESTIO_NG" {
  allocation_id = aws_eip.HESTIO_EIP1.id
  subnet_id     = aws_subnet.HESTIO_PB_SN.id
  tags = {
    Name = "HESTIO_NG"
  }
}

#Creating the  Frontend Security group that will be used for the public VM
resource "aws_security_group" "HESTIO_SG_FT" {
  name        = "HESTIO_SG_FT"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.HESTIO_VPC.id
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "HESTIO_SG_FT"
  }
}
#Creating the Backend Security group that will be used to SSH in to the private VM
resource "aws_security_group" "HESTIO_SG_BK" {
  name        = "HESTIO_SG_BK"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.HESTIO_VPC.id
  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.HESTIO_SG_FT.id}"]
  }
  egress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "HESTIO_SG_BK"
  }
}
#Creating a public Route Table which is linked to the internet gateway
resource "aws_route_table" "HESTIO_PUB_RT" {
  vpc_id = aws_vpc.HESTIO_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.HESTIO_IGW.id
  }
  tags = {
    Name = "HESTIO_PUB_RT"
  }
}
#Creating a private Route Table which is linked to the NAT gateway
resource "aws_route_table" "HESTIO_PRI_RT" {
  vpc_id = aws_vpc.HESTIO_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.HESTIO_NG.id
  }
  tags = {
    Name = "HESTIO_PRI_RT"
  }
}
#Associating the Pubic subnet  to Public RT
resource "aws_route_table_association" "HESTIO_PUB_ASS_1" {
  subnet_id      = aws_subnet.HESTIO_PB_SN.id
  route_table_id = aws_route_table.HESTIO_PUB_RT.id
}
#Associating the public Subnet to Private RT
resource "aws_route_table_association" "HESTIO_PRI_ASS_1" {
  subnet_id      = aws_subnet.HESTIO_PR_SN.id
  route_table_id = aws_route_table.HESTIO_PRI_RT.id
}
#Creating key pair for the VM
resource "aws_key_pair" "HESTIO_KEY" {
  key_name   = "HESTIO_KEY"
  public_key = file(var.path_to_public_key)
}

#Creating the  Elastic IP FOR VM WITH THE PUBLIC SUBNET
resource "aws_eip" "HESTIO_EIP2" {
  vpc = true
  tags = {
    Name = "HESTIO_EIP2"
  }
}
#Creating the public VM
resource "aws_instance" "HESTIO_EC2_1" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.HESTIO_PB_SN.id
  vpc_security_group_ids = [aws_security_group.HESTIO_SG_FT.id]
  key_name               = "HESTIO_KEY"

  tags = {
    Name = "HESTIO_EC2_1"
  }
}
#eip association to vm with pubic subnet
resource "aws_eip_association" "EIP_ASSOC_TO_HESTIO_EC2_1" {
  instance_id   = aws_instance.HESTIO_EC2_1.id
  allocation_id = aws_eip.HESTIO_EIP2.id
}
#Creating the private VM
resource "aws_instance" "HESTIO_EC2_2" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.HESTIO_PR_SN.id
  vpc_security_group_ids = [aws_security_group.HESTIO_SG_BK.id]
  key_name               = "HESTIO_KEY"

  tags = {
    Name = "HESTIO_EC2_2"
  }
}
