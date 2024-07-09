
# resource "aws_lightsail_domain" "main" {
#   domain_name = var.domain_name
# }

# resource "aws_lightsail_domain_entry" "echo" {
#   domain_name = aws_lightsail_domain.main.domain_name
#   name        = var.environment 
#   type        = "CNAME"
#   target      = aws_lightsail_lb.echo.dns_name  # needs to be an IP :(
# }

# add lb cert validation options
data "aws_route53_zone" "main" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "echo" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.environment
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 90
  }

  set_identifier = var.environment
  records        = [aws_lightsail_lb.echo.dns_name]
}

resource "aws_route53_record" "echo_domain_validation_records" {
  # these map values should be stored somewhere else..
  for_each = {
    for dvo in aws_lightsail_lb_certificate.echo.domain_validation_records : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}
