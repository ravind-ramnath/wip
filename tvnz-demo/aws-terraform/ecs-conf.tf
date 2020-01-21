resource "aws_security_group" "elb_sg" {
        name = "elb_sg"
        description = "Security Group - Elastic Load Balancer"
        vpc_id = "${aws_vpc.vpc.id}"

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 8080
                to_port = 8080
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

resource "aws_security_group" "ecs_sg" {
        name = "ecs_sg"
        description = "Security Group - Elastic Container Service"
        vpc_id = "${aws_vpc.vpc.id}"

        ingress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                security_groups = ["${aws_security_group.trust_sg.id}"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

resource "aws_elb" "elb" {
        name = "wordpress"
        subnets = ["${aws_subnet.public.0.id}", "${aws_subnet.public.1.id}"]
        cross_zone_load_balancing = true
        idle_timeout = 400
        security_groups = ["${aws_security_group.trust_sg.id}", "${aws_security_group.elb_sg.id}"]

        listener {
                instance_port = 80
                instance_protocol = "http"
                lb_port = 80
                lb_protocol = "http"
        }

        health_check {
                healthy_threshold = 2
                unhealthy_threshold = 10
                timeout = 5
                target = "HTTP:80/readme.html"
                interval = 30
        }
}

resource "tls_private_key" "ecs_key_pair" {
        algorithm = "RSA"
        rsa_bits  = 4096
}

resource "aws_key_pair" "ecs_generated_key" {
        key_name   = "ecs-demo"
        public_key = "${tls_private_key.ecs_key_pair.public_key_openssh}"
}

resource "aws_iam_role" "role" {
        name = "role"
        assume_role_policy = "${file("task-definitions/role.json")}"
}

resource "aws_iam_instance_profile" "profile" {
        name = "profile"
        path = "/"
        roles = ["${aws_iam_role.role.name}"]
}

resource "aws_launch_configuration" "ecs_lc" {
        name = "ecs_lc"
        image_id = "${lookup(var.ami, var.aws_region)}"
        instance_type = "${var.instance-type}"
        associate_public_ip_address = true
        key_name = "${aws_key_pair.generated_key.key_name}"
        iam_instance_profile = "${aws_iam_instance_profile.profile.name}"
        security_groups = ["${aws_security_group.trust_sg.id}", "${aws_security_group.ecs_sg.id}"]
        user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.wp-cluster.name} > /etc/ecs/ecs.config"
        depends_on = ["aws_key_pair.ecs_generated_key", "aws_ecs_cluster.wp-cluster"]
}

resource "template_file" "wp-json" {
        template = "${file("task-definitions/wp-task.json")}"

        vars {
                database_endpoint = "${aws_db_instance.wordpressdb.address}"
                database_name = "${var.database_name}"
                database_user = "${var.database_user}"
                database_password = "${var.database_password}"
        }
}

resource "aws_ecs_task_definition" "wp-task" {
        family = "terraform"
        container_definitions = "${template_file.wp-json.rendered}"
}

resource "aws_iam_role_policy" "service_role_policy" {
        name = "service_role_policy"
        policy = "${file("task-definitions/service-role-policy.json")}"
        role = "${aws_iam_role.role.id}"
}

resource "aws_iam_role_policy" "instance_role_policy" {
        name = "instance_role_policy"
        policy = "${file("task-definitions/instance-role-policy.json")}"
        role = "${aws_iam_role.role.id}"
}

resource "aws_ecs_service" "wordpress-service" {
        name = "wordpress-service"
        cluster = "${aws_ecs_cluster.wp-cluster.id}"
        task_definition = "${aws_ecs_task_definition.wp-task.arn}"
        desired_count = 1
        iam_role = "${aws_iam_role.role.arn}"
        depends_on = ["aws_iam_role_policy.service_role_policy"]

        load_balancer {
                elb_name = "${aws_elb.elb.id}"
                container_name = "wordpress-app"
                container_port = 80
        }
}

resource "aws_autoscaling_policy" "asg_policy" {
        name = "ASG-Policy-CPU-Usage"
        scaling_adjustment = 1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        autoscaling_group_name = "${aws_autoscaling_group.ecs_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
        alarm_name = "CPU-Usage-Alarm"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = 120
        statistic = "Average"
        threshold = "70"
        dimensions {
                AutoScalingGroupName = "${aws_autoscaling_group.ecs_asg.name}"
        }
        alarm_description = "CPU Usage Alarm"
        alarm_actions = ["${aws_autoscaling_policy.asg_policy.arn}"]
}

resource "aws_autoscaling_group" "ecs_asg" {
        name = "ECS-AutoScalingGroup"
        vpc_zone_identifier = ["${aws_subnet.private.0.id}","${aws_subnet.private.1.id}"]
        max_size = 5
        min_size = 2
        health_check_grace_period = 300
        health_check_type = "EC2"
        launch_configuration = "${aws_launch_configuration.ecs_lc.name}"
}

resource "aws_ecs_cluster" "wp-cluster" {
        name = "wordpress"
}
