terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
  }
}

provider "aws" {
  region = "me-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "cnaap"
    Demo = "Terraform"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name"  = "Main"
    "Owner" = "cnapp"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "webserver" {
  name        = "Webserver"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
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
    Name = "Allow traffic"
  }
}

resource "aws_launch_template" "cnappuscase" {
  name_prefix   = "cnappusecase"
  image_id      = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "cnapp" {
  availability_zones = ["me-south-1"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.cnappuscase.id
    version = "$Latest"
  }
}

resource "aws_instance" "web" {
  ami                    = var.amis[var.region]
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
#!/bin/bash
apt-get -y update
apt-get -y install nginx
service nginx start
echo fin v1.00!
EOF

  tags = {
    Name = "cnapp"
  }
}
