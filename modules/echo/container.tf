data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_lightsail_instance" "echo" {
  name              = "${var.environment}-echo"
  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = "amazon_linux_2"
  bundle_id         = "nano_3_0"
  user_data         = <<EOF
#!/bin/bash

sudo yum update
sudo yum install docker -y
sudo systemctl enable --now docker
sudo docker run --rm -p 80:80 docker.io/hashicorp/http-echo:1.0 -listen :80 -text ${var.environment}

EOF

  tags   = var.tags
}

resource "aws_lightsail_instance_public_ports" "echo" {
  instance_name = aws_lightsail_instance.echo.name

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }
}
