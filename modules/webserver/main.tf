# creating security groups
resource "aws_default_security_group" "myapp-sg" {
  vpc_id = var.vpc_id
   tags = {
    Name = "${var.env_prefix}-default-sg"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
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
    values = [var.image_name]
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


resource "aws_key_pair" "ssh-key" {
  key_name = "terraform-learning"
  public_key = file(var.my_public_key_location) # 'file' is used to refer the location of the key.
}

# create ec2 instance
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id

  instance_type = var.instance_type

  subnet_id = var.subnet_id

  # we can define list of security-groups here
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]

  availability_zone = var.avail_zone

  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name

# this only be executed once, passing data to aws.
  user_data = file("entry-script.sh") 
}
  #   tags = {
  #   Name = "${var.env_prefix}-server"
  # }