provider "aws" {
  region = "ap-south-1"

}

# using existing module from terraform registary and modified it.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name = "${var.env_prefix}-subnet-1"}
   tags = {
    Name = "${var.env_prefix}-vpc"
    }
}


# 'module' is used to reference it from other configuration file.

  # 1.values are defined in .tfvars file
  # 2.set values in variables.tf in root
  # 3.values are passed to child modules as arguments
  # 4.via variables.tf in child module

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = module.vpc.vpc_id
  env_prefix = var.env_prefix
  my_public_key_location = var.my_public_key_location
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0] # instance launched in this subnet, if you don't specify it will be launched in default subnet.
  avail_zone = var.avail_zone
  image_name = var.image_name
  my_ip = var.my_ip

}
