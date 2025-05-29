# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "myvpc"
  }
}

# public subnet
resource "aws_subnet" "publicSubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.publicSubnet_cidr_block
  availability_zone       = var.availability_zone_public_subnet
  map_public_ip_on_launch = true
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Public Route Table
resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.publicSubnet.id
  route_table_id = aws_route_table.publicRouteTable.id
}


//key pair making, ready to attach
resource "aws_key_pair" "vinitkey" {
  key_name   = "vinit-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

//security group making ready to attach
resource "aws_security_group" "my_security_group1" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend_security_group1"
  }
}

//security group making ready to attach
resource "aws_security_group" "my_security_group2" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend_security_group2"
  }
}


#public ec2 instance-1
resource "aws_instance" "publicInstance1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.vinitkey.key_name
  security_groups             = [aws_security_group.my_security_group1.id]
  subnet_id                   = aws_subnet.publicSubnet.id
  associate_public_ip_address = true
  tags = {
    Name = "express-frontend"
  }
}

#public ec2 instance-2
resource "aws_instance" "publicInstance2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.vinitkey.key_name
  security_groups             = [aws_security_group.my_security_group2.id]
  subnet_id                   = aws_subnet.publicSubnet.id
  associate_public_ip_address = true
  tags = {
    Name = "flask-backend"
  }
}
