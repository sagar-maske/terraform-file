terraform {
required_provider{
aws = {
source = " hashicorp/aws"
version = "~> 5.0"
}
}
}

provider "aws" {
region = "ap_south_1"
access_key = " "
secrete_key = " "
}

resource "aws_vpc" "demo_vpc" {
cidr_block = "10.10.0.0/16"
tags ={
name = "vpc-1"
}
}

resource "aws_subnet" "public_subnet" {
vpc_id = aws_vpc.demo_vpc.id
cidr_block = "10.10.1.0/24"
tags = {
name= "demo_subnet"
}
}

resource "aws_internet_gateway" "demo_gtwy" {
vpc_id = aws_vpc.demo_vpc.id
tags = {
name = "demo_int_gateway"
}
}

resource "aws_route_table" "route_table" {

vpc_id = aws_vpc.demo_vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.demo_gtwy.id
}
tags = {
name = "demo_rt"
}
}

resource "aws_route_table_association" "demo_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "demo_sg_grp" {
  name        = "demo_sg_grp"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_instance" "instance-1" {
ami = "ami-007020fd9c84e18c7"
instance_type= "t2.micro"
subnet_id = aws_subnet.public_subnet.id
key_name = "access-key"
vpc_security_group_ids = [aws_security_group.demo_sg_grp.id]
}

