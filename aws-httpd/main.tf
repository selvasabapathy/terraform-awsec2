terraform {
    required_version = ">=0.12"
}

resource "aws_instance" "ec2_httpd" {
    ami                     = var.ami_id
    instance_type           = var.ec2_instance_type
    key_name                = "aws_key"
    vpc_security_group_ids  = [aws_security_group.http.id]

    user_data = <<EOF
        #!/bin/bash

        # get admin privileges
        sudo su

        # install httpd (Linux 2 version)
        yum update -y
        yum install -y httpd.x86_64
        systemctl start httpd.service
        systemctl enable httpd.service
        echo "hello, world! from $(hostname -f)" > /var/www/html/index.html
        EOF
}

resource "aws_security_group" "http" {
    name        = "ec2-http-sg"
    description = "EC2 Instances with HTTPd"

    ingress {
        from_port   = 80
        protocol    = "TCP"
        to_port     = 80
        cidr_blocks = ["104.129.205.42/32"]
    }

    ingress {
        from_port   = 22
        protocol    = "TCP"
        to_port     = 22
        cidr_blocks = ["104.129.205.42/32"]
    }

    egress {
        from_port   = 0
        protocol    = "-1"
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "deployer" {
    key_name   = "aws_key"
    public_key = "<insert public key from ~/.ssh/id_rsa.pub>"
}