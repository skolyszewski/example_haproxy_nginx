provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "centos7" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
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

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow inbound 80"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "lbed_webserver" {
  ami           = data.aws_ami.centos7.id
  instance_type = "t2.micro"
  security_groups = [
      aws_security_group.allow_http.name
  ]

  tags = {
    Name = "lbed_webserver"
  }
}
