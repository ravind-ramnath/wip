# Create a VPC where instances will reside
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags {
        Name = "ubuntu_vpc"
    }
}

# Create a subnet that will encompass the instances
resource "aws_subnet" "main" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_availability_zone}"

    tags {
        Name = "ubuntu_subnet"
    }
}

# Grant the VPC internet access on its main route table - demo purposes
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Create an internet gateway to give our subnet access to the outside world - demo purposes
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "ubuntu_gw"
    }
}


