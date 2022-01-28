terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    }
}

# Provide configuration: plugin that Terraform uses to
# translate the API interactions with the AWS service

provider "aws" {
    region = "us-east-1"
    profile = var.aws_profile
}

# VPC: The resource block defines a pieace of infrastructure
resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    tags = {
        Name = "Postgresql-vpc"
    }
}

# Internet gateway: allow the VPC to connect to the internet
resource "aws_internet_gateway" "main_gw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main_gw"
    }
}

# VPC route table: this route table is used by all 
# subnets not associated with a different route table
resource "aws_default_route_table" "rout_table" {
    default_route_table_id = aws_vpc.main.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_gw.id
    }
    tags = {
        Name = "default route table"
    }
}

# Subnet that can be accessed from the internet (SSH)
resource "aws_subnet" "my_public_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.subnet
    availability_zone       = var.aws_availability_zone
    map_public_ip_on_launch = true # This line makes the subnet public
    tags = {
        Name = "my-project-public-subnet"
    }
}

# AWS Security Group
# Allowing traffic incoming on port 22 via ssh
# Allowing all outgoing traffic from the instance
resource "aws_security_group" "db_security_group" {
    name        = "PostgreSQL"
    description = "Allow SSH and PostgreSQL inbound traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
        description = "SSH"
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
        Name = "allow_tls"
    }
}

# Public key to use to login to the EC2 instance
resource "aws_key_pair" "ssh_key" {
    key_name   = "aws_postgresql"
    public_key = file("postgresql_aws.pub")
}

# PostgreSQL DB Instance
resource "aws_instance" "web" {
    ami           = "ami-00b21f32c4929a15b" # Amazon Linux 2 ARM 
    instance_type = var.instance_type
    key_name      = aws_key_pair.ssh_key.key_name
    user_data = templatefile("install_postgres.sh", {
        pg_hba_file = templatefile("pg_hba.conf", { allowed_ip = "0.0.0.0/0" }),
    })
    subnet_id                   = aws_subnet.my_public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.db_security_group.id]
    tags = {
        Name = "PostgreSQL"
    }
}

# Show the public IP of the newly created instance
output "instance_ip_addr" {
    value = aws_instance.web.*.public_ip
}