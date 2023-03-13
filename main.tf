provider "aws" {
  region = "ap-south-1"
#   access_key = "AKIAZ3QKAOEWF6EBW2VS"
#   secret_key = "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"
}

variable "cidr_blocks" {
    description = "cidr-blocks"
    # default = 
    type = list(string)
  
}

resource "aws_vpc" "devlopment-vpc" {
    cidr_block = var.cidr_blocks[1]
    tags = {
      "name" = "devlopment"
    }
}



resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.devlopment-vpc.id
    cidr_block = var.cidr_blocks[0]
    availability_zone = "ap-south-1a"
    tags = {
      "name" = "subnet-1-dev"
    }
}

data "aws_vpc" "existing-vpc" {
    default = "true"
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing-vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "ap-south-1a"
    tags = {
        "name" = "subnet-1-default"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.devlopment-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id 
}

