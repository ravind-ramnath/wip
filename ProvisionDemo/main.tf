# Provider details required
provider "aws" {
  region = "${var.aws_region}"
  access_key = "ADD YOUR KEY"
  secret_key  = "ADD YOUR SECRET"
}

resource "tls_private_key" "ubuntu" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.ubuntu.public_key_openssh}"
}

# Instance with required parameters
resource "aws_instance" "main" {
  # Count for demo purposes
  count = 1
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${var.aws_ec2_user}"
  }

  # Availabilty zones - for HA
  availability_zone = "${var.aws_availability_zone}"

  # Instance types based on region - script to dyanmically render. Hardcoded for West Coast for demo purposes.
  instance_type = "${var.aws_instance_type}"

  # User Data for after provisioning configuration. Ansible Playbook could be used. Cloud-Init used for demo purposes.
  user_data = "${data.template_file.udata.rendered}"  

  # Lookup the correct AMI based on the region
  # Hardcoded for demo (west Coat)
  ami = "${var.aws_ami_ubuntu}"

  # SSH keypair created above. Used for login.
  key_name = "${aws_key_pair.generated_key.key_name}"

  # Our Security group to allow SSH access only
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  # Subnet within VPC
  subnet_id = "${aws_subnet.main.id}"
  
  tags {
        Name = "ubuntu-${count.index}"
    }
}

# User Data template with required configuration information
data "template_file" "udata" {
    template = "${file("user-data.tpl")}"    
}