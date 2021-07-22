##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = "${var.aws_region}"
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {
  enable_dns_hostnames = "true"
}

# Subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Default subnet for eu-central-1a"
  }
}

# Security Group
resource "aws_security_group" "default" {
  name = "sgswarmcluster"
  vpc_id      = aws_default_vpc.default.id

  # Allow all inbound
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all inbound
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Enable ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  tags = {
    Name = "EfsExample"
  }
}

resource "aws_efs_mount_target" "efs-mount" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${aws_default_subnet.default_az1.id}"
  security_groups = ["${aws_security_group.default.id}"]
}

# EC2 Instances
resource "aws_key_pair" "default"{
  key_name = "clusterkp"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "master" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.default.id}"
  subnet_id              = "${aws_default_subnet.default_az1.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags = {
    Name  = "master"
  }
}

resource "aws_instance" "worker1" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.default.id}"
  subnet_id              = "${aws_default_subnet.default_az1.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags = {
    Name  = "worker 1"
  }
}

resource "aws_instance" "worker2" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.default.id}"
  subnet_id              = "${aws_default_subnet.default_az1.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags = {
    Name  = "worker 2"
  }
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("../ansible/inventory.tmpl",
    {
      master-dns = aws_instance.master.public_dns,
      master-ip = aws_instance.master.public_ip,
      master-priv-ip = aws_instance.master.private_ip,
      master-id = aws_instance.master.id,
      worker1-dns = aws_instance.worker1.public_dns,
      worker1-ip = aws_instance.worker1.public_ip,
      worker1-priv-ip = aws_instance.worker1.private_ip,
      worker1-id = aws_instance.worker1.id,
      worker2-dns = aws_instance.worker2.public_dns,
      worker2-ip = aws_instance.worker2.public_ip,
      worker2-priv-ip = aws_instance.worker2.private_ip,
      worker2-id = aws_instance.worker2.id
    }
  )
  filename = "../ansible/inventory"
}
