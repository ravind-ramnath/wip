# Default security group to access the instance over SSH only
resource "aws_security_group" "main" {
  name        = "ubuntu_sg"
  description = "Demo SG for Ubuntu"
  vpc_id      = "${aws_vpc.main.id}"

  # SSH access from anywhere for demo purposes.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access for demo purposes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




