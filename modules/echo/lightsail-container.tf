# resource "aws_lightsail_certificate" "echo" {
#   name                      = "${var.name_prefix}.echo-certificate"
#   domain_name               = aws_lightsail_domain_entry.echo.domain_name
#   subject_alternative_names = ["${var.environment}.${aws_lightsail_domain_entry.echo.domain_name}"]
  
#   tags   = var.tags
# }

# http-echo container service

# Error: creating Lightsail Container Service (dev-echo):
#        operation error Lightsail: CreateContainerService, https response
#        error StatusCode: 400, RequestID: [..], 
#        InvalidInputException: Sorry, you've either reached or will exceed 
#                               your maximum limit of Lightsail Container Services.
# resource "aws_lightsail_container_service" "echo" {
#   name        = "${var.environment}-echo"
#   power       = "nano"
#   scale       = 1
#   is_disabled = false

#   public_domain_names {
#     certificate {
#       certificate_name = aws_lightsail_certificate.echo.name
#       domain_names = [
#         aws_lightsail_certificate.echo.domain_name,
#       ]
#     }
#   }

#   tags   = var.tags
# }

# NOTE: Terraform cannot destroy it, removing this resource
#       from your configuration will remove it from your
#       statefile and Terraform management!
# resource "aws_lightsail_container_service_deployment_version" "echo" {
#   service_name = aws_lightsail_container_service.echo.name

#   container {
#     container_name = "http-echo"
#     image          = "hashicorp/http-echo:1.0"

#     command = ["-listen", "80", "-text", "${var.environment}"]

#     ports = {
#       80 = "HTTP"
#     }
#   }

#   public_endpoint {
#     container_name = "http-echo"
#     container_port = 80

#     health_check {
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       timeout_seconds     = 2
#       interval_seconds    = 5
#     }
#   }
# }




