provider "aws" {
  region = "us-east-1"
}

# Just an example keypair so everyone can run the tf from scratch without
# depending on existing keys and using them in the cloud
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "webservers_admin_key" {
  key_name   = "webservers_admin_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

data "aws_ami" "ubuntu_bionic" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200430"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ingress_http" {
  name        = "ingress_http"
  description = "Allow inbound 80"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ingress_http"
  }
}

resource "aws_security_group" "egress_https" {
  name        = "egress_https"
  description = "Allow outbound 443"

  egress {
    description = "Allow outbound HTTPS (for docker registry)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "egress_https"
  }
}

resource "aws_security_group" "egress_http" {
  name        = "egress_http"
  description = "Allow outbound 80"

  egress {
    description = "Allow outbound HTTP (for system packages)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "egress_http"
  }
}

resource "aws_security_group" "ingress_ssh" {
  name        = "ingress_ssh"
  description = "Allow inbound 22"

  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ingress_ssh"
  }
}

resource "aws_instance" "lb_webserver" {
  ami           = data.aws_ami.ubuntu_bionic.id
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.ingress_http.name,
    aws_security_group.ingress_ssh.name,
    aws_security_group.egress_https.name,
    aws_security_group.egress_http.name,
  ]
  key_name = aws_key_pair.webservers_admin_key.key_name

  tags = {
    Name = "lb_webserver"
  }
}

# That's not a great approach in a real-world scenario.
# But in a real-world, we would use existing ssh keys and pass them
# as variables instead.
# This is done like that so we don't need to have pre-existing keys
# and can still access the machine for the next provisioning steps.
output "ssh_private_key" {
  value = tls_private_key.ssh_key.private_key_pem
}
