resource "aws_vpc" "vpc" {
        cidr_block = "10.130.0.0/16"
        enable_dns_hostnames = true
        tags {
                Name = "ECS-VPC"
                Description = "ECS VPC"
                Deployed = "Terraform"
        }
}

resource "aws_route_table" "public-rt" {
        vpc_id = "${aws_vpc.vpc.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.igw.id}"
        }

        tags {
                Name = "Public Route Table"
        }
}

resource "aws_subnet" "public" {
        vpc_id = "${aws_vpc.vpc.id}"
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        cidr_block = "${lookup(var.public_subnet_cidr, count.index)}"
        availability_zone = "${element(split(",", lookup(var.availability_zones, var.aws_region)), count.index)}"
        map_public_ip_on_launch = true

        tags {
                Name = "Public Subnet ${count.index}"
        }
}

resource "aws_route_table_association" "public-rt" {
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
        route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_subnet" "private" {
        vpc_id = "${aws_vpc.vpc.id}"
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        cidr_block = "${lookup(var.private_subnet_cidr, count.index)}"
        availability_zone = "${element(split(",", lookup(var.availability_zones, var.aws_region)), count.index)}"
        map_public_ip_on_launch = false

        tags {
                Name = "Private Subnet ${count.index}"
        }
}

resource "aws_eip" "nat_eip" {
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}" 
        subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
        depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "private-rt" {
        vpc_id = "${aws_vpc.vpc.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_nat_gateway.nat_gw.0.id}"
        }

        tags {
                Name = "Private Route Table"
        }
}

resource "aws_route_table_association" "private-rt" {
        count = "${length(split(",", lookup(var.availability_zones, var.aws_region)))}"
        subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
        route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_internet_gateway" "igw" {
        vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "trust_sg" {
        name = "trust_sg"
        description = "Trusted Hosts - SSH"
        vpc_id = "${aws_vpc.vpc.id}"
}