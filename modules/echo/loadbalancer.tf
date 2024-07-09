resource "aws_lightsail_lb" "echo" {
  name              = "${var.name_prefix}.echo-lb"
  health_check_path = "/"
  instance_port     = "80"

  tags   = var.tags
}

resource "aws_lightsail_lb_attachment" "echo" {
  lb_name       = aws_lightsail_lb.echo.name
  instance_name = aws_lightsail_instance.echo.name

  lifecycle {
    replace_triggered_by = [
      # Needs to be recreated on instance changes
      aws_lightsail_instance.echo,
    ]
  }
}

resource "aws_lightsail_lb_certificate" "echo" {
  name                      = "${var.name_prefix}.echo-lb-cert"
  lb_name                   = aws_lightsail_lb.echo.id
  domain_name               = "${var.environment}.${var.domain_name}"
}

resource "aws_lightsail_lb_certificate_attachment" "echo" {
  lb_name          = aws_lightsail_lb.echo.name
  certificate_name = aws_lightsail_lb_certificate.echo.name

#   depends_on = [
#     aws_route53_record.echo_domain_validation_records
#   ]
}

resource "aws_lightsail_lb_https_redirection_policy" "echo" {
  lb_name = aws_lightsail_lb.echo.name
  enabled = true

  depends_on = [
    aws_lightsail_lb_certificate_attachment.echo
  ]
}