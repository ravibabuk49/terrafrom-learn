provider "aws" {
  region = "ap-south-1"

}
# variables
variable vpc_cidr_blocks {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable my_public_key_location {}

# create vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
      "Name" = "${var.env_prefix}-vpc"
    }
}

# create subnet in your specified vpc.
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.env_prefix}-subnet-1"
    }
}

# create internet-gateway and attach it to vpc. 
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
      Name = "${var.env_prefix}-igw"
    }
  
}

# creating route-table and assign it with igw to access the internet.
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
       Name = "${var.env_prefix}-rtb"
    }
}

# you can also use default route table 

# resource "aws_default_route_table" "main-rtb" {
#   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  
#   route = {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
  
# }


# assosiate subnet with (in)route table
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
  
}


# creating security groups
resource "aws_security_group" "myapp-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
   tags = {
    Name = "${var.env_prefix}-sg"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "these rules are used to fetch data from outside(internet)"
    prefix_list_ids = []
  }
 
}


# set ami dynamically.
#create amazon machine image(ami) for ec2 dynamically.

data "aws_ami" "latest-amazon-linux-image" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


output "ami-id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}


resource "aws_key_pair" "ssh-key" {
  key_name = "terraform-learning"
  public_key = file(var.my_public_key_location) # 'file' is used to refer the location of the key.
}

# create ec2 instance
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id

  # we can define list of security-groups here
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]

  availability_zone = var.avail_zone

  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name

# this only be executed once
  user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}


