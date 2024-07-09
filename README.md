# tftest

-----

## Descripton

Deploys echo-test instances with lightsail for two environments: `dev` and `prod`.

The deployment needs to be done in 3 steps:
- load balancer certificate -> resolves `domain_validation_records`
- rest -> `aws_lightsail_lb_certificate_attachment` needs a validated certificate, so maybe this might fail the first time bc the certificate is not yet validated

The destruction needs some manual action:
- `aws_lightsail_lb_certificate_attachment.echo` -> otherwise the load balancer can not be deleted
- `aws_route53_record.echo_domain_validation_records` -> needs data from the load balancer and sadly there is no `depends_on_delete`
- use aws cli to delete the load balancer with force flag -> or use the script
- rest

## Deploy

change env accordingly

```sh
cd envs/prod
terragrunt apply --target="aws_lightsail_lb_certificate.echo" --auto-approve
terragrunt apply --target="aws_route53_record.echo_domain_validation_records" --auto-approve
terragrunt apply --auto-approve  # may fail until the certificate is validated

```

## Destroy

change env accordingly

```sh
./delete_lb_cert.sh prod
# if it does not finish: go to lightsail console -> networking -> delete load balancer manually..
cd envs/prod
terragrunt state list
# work your way through :-/
# terragrunt destroy --target="<resource>" --auto-approve
terragrunt destroy --target="data.aws_route53_zone.main" --auto-approve
terragrunt destroy --target="aws_lightsail_lb_attachment.echo" --auto-approve
terragrunt destroy --target="aws_lightsail_instance.echo" --auto-approve
terragrunt destroy --auto-approve
```

### Lessons learned
dont try:
```sh
aws lightsail delete-load-balancer --load-balancer-name $(terragrunt state pull|jq -r '.outputs.aws_lightsail_lb.value.name') --region 'us-east-1'
terragrunt destroy --target="aws_lightsail_lb.echo" --auto-approve
terragrunt destroy --target="aws_lightsail_lb_certificate.echo" --auto-approve
```


### Problems had

- use foreign (preconfigured via route 53) domain in `aws_lightsail_domain` to be able to use the automatic entry functionality
- break the: `Cycle: aws_lightsail_certificate.echo, aws_lightsail_container_service.echo, aws_lightsail_domain_entry.echo`
    - `terragrunt apply -target="aws_lightsail_certificate.echo"`
    - `terragrunt apply -target="aws_lightsail_lb_certificate.echo"`
- `Error: creating Lightsail Container Service (dev-echo): operation error Lightsail: CreateContainerService, https response error StatusCode: 400, RequestID: 6c5db85d-3062-4954-9973-bd538ae5aa77, InvalidInputException: Sorry, you've either reached or will exceed your maximum limit of Lightsail Container Services.`yes
    - https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-changing-container-service-capacity.html
    - nope, want to use terraform... -> use EC2
