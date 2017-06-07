provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_primary_region}"
}

resource "aws_security_group" "sg_default" {
  name = "sg_default"
  description = "Default security group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["172.16.0.0/12"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "app-01" {
  key_name = "app-01"
  ami           = "${var.aws_default_app_ami_name}"
  instance_type = "${var.aws_default_app_instance_type}"
  key_name = "${var.aws_default_key_pairs_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_default.id}"]
  depends_on = ["aws_security_group.sg_default"]

  provisioner "file" {
    source = "../scripts/firstboot.sh"
    destination = "/tmp/firstboot.sh"
    
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("../files/aws.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/firstboot.sh",
      "/tmp/firstboot.sh ${var.stack_head_ip_address}"
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("../files/aws.pem")}"
    }
  }
}
