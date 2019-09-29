variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "aws_availability_zone" {
  description = "AWS Resourses Availablity Zone."
  default     = "us-west-2a"
}

variable "aws_ami_ubuntu" {
  description = "Ubuntu 16.04 LTS Server"
  default     = "ami-0b37e9efc396e4c38"
}

variable "aws_instance_type" {
  description = "AWS instance type to create"
  default     = "t2.large"
}

variable "aws_ec2_user" {
  description = "AWS EC2 User"
  default     = "ubuntu"
}

variable "key_name" {
  description = "Key Pair name for Account SSH login"
  default     = "ubuntu"
}