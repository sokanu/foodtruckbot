#!/bin/bash

echo "Entrypoint script running..."
echo "Fetching environment variables..."

# Fetch SSM parameters from AWS
TMP_ENV_VARS=$(aws ssm get-parameters-by-path --path /$PROJECT/$ENVIRONMENT/$SERVICE --recursive --with-decryption)
if [ $? -gt "0" ]; then
    >&2 echo "Failed to fetch SSM parameters from AWS, exiting"
    exit 1
fi

# Transform SSM parameters into Key=Value format
TMP_ENV_VARS=$(echo "$TMP_ENV_VARS" | jq -r '.Parameters | to_entries | .[] | .value.Name + "=\"" +.value.Value + "\""')
if [ $? -gt "0" ]; then
    >&2 echo "Failed to parse SSM parameters using jq, exiting"
    exit 1
fi

# Extract the prefixed /$PROJECT/$ENVIRONMENT/$SERVICE bit
TMP_ENV_VARS=$(echo "$TMP_ENV_VARS" | cut -d"/" -f5-)
if [ $? -gt "0" ]; then
    >&2 echo "Failed to parse SSM parameters using jq, exiting"
    exit 1
fi

# Dump the contents to a temporary file
echo "$TMP_ENV_VARS" > /tmp/.env

echo "Environment variables have been fetched..."

# Add the ECS Instance IP to the Environment
# RW: 3/29/2019 - Not sure why we do this?
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo -e "ECS_INSTANCE_IP=$IP" >> /tmp/.env

# Source ENV.
echo "Environment variables have been set..."
source /tmp/.env
export $(cut -d= -f1 /tmp/.env)

# Cleanup after ourselves
echo "Cleaning up after ourselves..."
rm -rf /tmp/.env
unset TMP_ENV_VARS

echo "Running your command..."

# Exec given command.
exec "$@"
