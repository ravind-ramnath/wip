variable "aws_access_key" {
        default = "<add your key here>"
}

variable "aws_secret_key" {
        default = "<add your secret here>"
}

variable "aws_region" {
        default = "us-east-1" #prefered region for demo but it can be changed - you will need to update the AMI list below if changed
}

variable "aws_account" {
        default = "<add your account number here>"
}

variable "instance-type" {
        default = "t2.micro"
}

variable "database_name" {
        default = "wpdb"
}

variable "database_user" {
        default = "wordpress"
}

variable "database_password" {
        default = "wpadmin2020"
}

variable "ami" {
        default = {
                "us-east-1" = "ami-cb2305a1"
                "us-west-1" = "ami-bdafdbdd"
                "us-west-2" = "ami-ec75908c"
        }
}

variable "availability_zones" {
        default = {
                "us-east-1" = "us-east-1b,us-east-1c"
                "us-west-1" = "us-west-1b,us-west-1c"
                "us-west-2" = "us-west-2a,us-west-2b"
        }
}

variable "public_subnet_cidr" {
        default = {
                "0" = "10.130.0.0/24"
                "1" = "10.130.1.0/24"
        }
}

variable "private_subnet_cidr" {
        default = {
                "0" = "10.130.2.0/24"
                "1" = "10.130.3.0/24"
        }
}