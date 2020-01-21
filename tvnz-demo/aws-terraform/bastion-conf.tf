resource "aws_instance" "bastion" {
  ami = "${lookup(var.ami, var.aws_region)}"
  instance_type = "${var.instance-type}"
  key_name = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.trust_sg.id}", "${aws_security_group.elb_sg.id}"]
  subnet_id = "${aws_subnet.public.0.id}"
  tags {
    Name = "bastion"
  }
}

resource "tls_private_key" "bastion-host" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "demo"
  public_key = "${tls_private_key.bastion-host.public_key_openssh}"
}