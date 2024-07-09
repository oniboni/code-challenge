#! /usr/bin/env bash

set -e

ENVIRONMENT=$1
echo "ENVIRONMENT: $ENVIRONMENT"

if [ -z "$ENVIRONMENT" ]; then
    echo "no env target given"
    exit 1
fi

ENV_DIR="envs/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo "environment does not exist in: ./$ENV_DIR"
    exit 1
fi

pushd $ENV_DIR

REMOTE_STATE=$(terragrunt state pull)
LOAD_BALANCER_NAME=$(echo $REMOTE_STATE |jq -r '.resources[] | select(.type == "aws_lightsail_lb").instances[0].attributes.id')
INSTANCE_NAME=$(echo $REMOTE_STATE |jq -r '.resources[] | select(.type == "aws_lightsail_instance").instances[0].attributes.id')
LOAD_BALANCER_CERT_NAME=$(echo $REMOTE_STATE |jq -r '.resources[] | select(.type == "aws_lightsail_lb_certificate").instances[0].attributes.name')

echo "LOAD_BALANCER_NAME: $LOAD_BALANCER_NAME"
echo "INSTANCE_NAME: $INSTANCE_NAME"
echo "LOAD_BALANCER_CERT_NAME: $LOAD_BALANCER_CERT_NAME"

echo Detaching instance from load balancer
aws lightsail detach-instances-from-load-balancer --load-balancer-name $LOAD_BALANCER_NAME --instance-names $INSTANCE_NAME --region 'us-east-1'
echo Force deleting load balancer certificate
aws lightsail delete-load-balancer-tls-certificate --load-balancer-name $LOAD_BALANCER_NAME --certificate-name $LOAD_BALANCER_CERT_NAME --region 'us-east-1' --force

CHECK_STATUS=$(aws lightsail get-operations --region 'us-east-1'|jq -r '.operations[] | select(.status != "Succeeded").id')

while [ -n "$CHECK_STATUS" ]; do
    echo Current jobs:
    echo "$CHECK_STATUS"
    sleep 2
    CHECK_STATUS=$(aws lightsail get-operations --region 'us-east-1'|jq -r '.operations[] | select(.status != "Succeeded").id')
done

popd

echo Done.