provider "aws" {
  region = "ap-south-1"

}

# create vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
      "Name" = "${var.env_prefix}-vpc"
    }
}

# 'module' is used to reference it from other configuration file.
module "myapp-subnet" {
  # 1.values are defined in .tfvars file
  # 2.set as values in variables.tf in root
  # 3.values are passed to child modules as arguments
  # 4.via variables.tf in child module
  source = "./modules/subnet" # path to our module.
  vpc_id = aws_vpc.myapp-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  env_prefix = var.env_prefix
  my_public_key_location = var.my_public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id#(name of the ouput)
  avail_zone = var.avail_zone
  image_name = var.image_name
  my_ip = var.my_ip

}
