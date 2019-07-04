#!/bin/bash

# Copy ENV from SSM to file.
aws ssm get-parameters-by-path --path /$PROJECT/$ENVIRONMENT/$SERVICE --recursive --with-decryption | \
jq -r '.Parameters | to_entries | .[] | .value.Name + "=\"" +.value.Value + "\""' | \
cut -d"/" -f5- > /tmp/.env

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo -e "ECS_INSTANCE_IP=$IP" >> /tmp/.env

# Source ENV.
source /tmp/.env
export $(cut -d= -f1 /tmp/.env)
rm -rf /tmp/.env

# Exec given command.
exec "$@"