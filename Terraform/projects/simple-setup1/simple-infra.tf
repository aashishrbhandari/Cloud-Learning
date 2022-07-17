terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/**

Create a 
 - VPC
 - 4 Subnets: 2 Public(us-east-1a, us-east-1b) & 2 Private(us-east-1a, us-east-1b) [Done]
 - 1 Route Table(for Private Subnet) : i.e NO Internet Gateway(IGW) attached [Done]
 - Use Main Route Table(for Public Subnet) : i.e With Internet Gateway(IGW) attached [Done]
 - 2 Security Group (1 Private Incoming:22 From SG-GROUP Public,Not Outgoing) (1 Public: 22 SSH Allow From: Internet )  [Done]
 - 1 IGW to be attached to the VPC Main Route Table  [Done]
 - 2 EC2 (1 in Private) (1 in Public: Elastic IP Assigned) 
 - 1 Elastic IP 

**/


# VPC


resource "aws_vpc" "DevTest_VPC" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = "DevTest_VPC"
  }
}


# Internet Gateway

resource "aws_internet_gateway" "DevTest_VPC_IGW" {
  vpc_id = aws_vpc.DevTest_VPC.id

  tags = {
    Name = "DevTest_VPC_IGW"
  }
}


# Public Subnet 1

resource "aws_subnet" "PublicSubnet_1" {
  vpc_id            = aws_vpc.DevTest_VPC.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PublicSubnet_1"
  }
}


# Private Subnet 1

resource "aws_subnet" "PrivateSubnet_1" {
  vpc_id            = aws_vpc.DevTest_VPC.id
  cidr_block        = "10.30.101.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PrivateSubnet_1"
  }
}


# Public Subnet 2

resource "aws_subnet" "PublicSubnet_2" {
  vpc_id            = aws_vpc.DevTest_VPC.id
  cidr_block        = "10.30.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PublicSubnet_2"
  }
}


# Private Subnet 2

resource "aws_subnet" "PrivateSubnet_2" {
  vpc_id            = aws_vpc.DevTest_VPC.id
  cidr_block        = "10.30.102.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PrivateSubnet_2"
  }
}


# Route Table (For Public Subnet) - Default Main RT of the VPC

resource "aws_default_route_table" "DevTest_VPC_Main_RT" {
  default_route_table_id = aws_vpc.DevTest_VPC.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevTest_VPC_IGW.id
  }

  tags = {
    Name = "DevTest_VPC_Main_RT"
  }
}


# Route Table (For Private Subnet)
resource "aws_route_table" "DevTest_VPC_Private_RT" {
  vpc_id = aws_vpc.DevTest_VPC.id

  tags = {
    Name = "DevTest_VPC_Private_RT"
  }
}


# Security Groups [Public]

resource "aws_security_group" "Public_SG" {
  name        = "Public_SG"
  description = "Public Instances Firewall"
  vpc_id      = aws_vpc.DevTest_VPC.id

  ingress {
    description = "SSH From Internet"
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
    Name = "Public_SG"
  }
}


# Security Groups [Private]

resource "aws_security_group" "Private_SG" {
  name        = "Private_SG"
  description = "Private Instances Firewall"
  vpc_id      = aws_vpc.DevTest_VPC.id

  ingress {
    description = "SSH From Same SG Machines"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  tags = {
    Name = "Private_SG"
  }
}


# Security GROUP : Rule

resource "aws_security_group_rule" "Private_SG_Rule2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.Private_SG.id
  source_security_group_id = aws_security_group.Public_SG.id
}

## Associate Private Subnet with PrivateRouteTable

resource "aws_route_table_association" "Private_to_Private" {
  subnet_id      = aws_subnet.PrivateSubnet_1.id
  route_table_id = aws_route_table.DevTest_VPC_Private_RT.id
}

resource "aws_route_table_association" "Private_to_Private2" {
  subnet_id      = aws_subnet.PrivateSubnet_2.id
  route_table_id = aws_route_table.DevTest_VPC_Private_RT.id
}

## Associate Implicitly Public Subnet with MainRouteTable

resource "aws_route_table_association" "Public_to_Main" {
  subnet_id      = aws_subnet.PublicSubnet_1.id
  route_table_id = aws_vpc.DevTest_VPC.default_route_table_id
}

resource "aws_route_table_association" "Public_to_Main2" {
  subnet_id      = aws_subnet.PublicSubnet_2.id
  route_table_id = aws_vpc.DevTest_VPC.default_route_table_id
}

## AWS EC2 Key Pairs

resource "aws_key_pair" "Access-Pair1" {
  key_name   = "Access-Pair1"
  public_key = "ssh-rsa <Put Your Public Key Here> Web-Server-Connector"
}


## EC2 Instance 

resource "aws_instance" "WebServer-1" {
  ami                         = "ami-0729e439b6769d6ab"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Public_SG.id]
  subnet_id                   = aws_subnet.PublicSubnet_1.id
  key_name                    = aws_key_pair.Access-Pair1.id

  tags = {
    Name = "WebServer-1"

  }
}

resource "aws_instance" "WebServer-2" {
  ami                         = "ami-0729e439b6769d6ab"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Public_SG.id]
  subnet_id                   = aws_subnet.PublicSubnet_2.id
  key_name                    = aws_key_pair.Access-Pair1.id

  tags = {
    Name = "WebServer-2"
  }
}


## EC2 Instance 

resource "aws_instance" "DBServer-1" {
  ami                    = "ami-0729e439b6769d6ab"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Private_SG.id]
  subnet_id              = aws_subnet.PrivateSubnet_1.id
  key_name               = aws_key_pair.Access-Pair1.id

  tags = {
    Name = "DBServer-1"

  }
}

resource "aws_instance" "DBServer-2" {
  ami                    = "ami-0729e439b6769d6ab"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Private_SG.id]
  subnet_id              = aws_subnet.PrivateSubnet_2.id
  key_name               = aws_key_pair.Access-Pair1.id

  tags = {
    Name = "DBServer-2"
  }
}

