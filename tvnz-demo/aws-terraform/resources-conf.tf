resource "aws_security_group" "db_sg" {
        name = "db_sg"
        description = "Security Group - MySQL RDS"
        vpc_id = "${aws_vpc.vpc.id}"

        ingress {
                from_port = 3306
                to_port = 3306
                protocol = "tcp"
                security_groups = ["${aws_security_group.trust_sg.id}"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        depends_on = ["aws_security_group.trust_sg"]
}

resource "aws_db_subnet_group" "default" {
        name = "private_group"
        description = "DB Group on Private Subnets"
        subnet_ids = ["${aws_subnet.private.0.id}", "${aws_subnet.private.1.id}"]
        tags {
                Name = "DB Security Group"
        }
        depends_on = ["aws_subnet.private"]
}

resource "aws_db_instance" "wordpressdb" {
        allocated_storage = 5
        engine = "mysql"
        engine_version = "5.7.19"
        instance_class = "db.t2.micro"
        name = "${var.database_name}"
        username = "${var.database_user}"
        password = "${var.database_password}"
        db_subnet_group_name = "${aws_db_subnet_group.default.name}"
        vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]        
        skip_final_snapshot = "true"
}