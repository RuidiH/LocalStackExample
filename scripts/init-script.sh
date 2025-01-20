#!/bin/bash

# Capture the bucket name from the first script argument
BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Bucket name not provided."
    exit 1
fi

echo "Using bucket: $BUCKET_NAME"

# Download the Go server binary from S3 using the passed bucket name
aws s3 cp s3://$BUCKET_NAME/go-server /home/ec2-user/go-server

# Set permissions for the binary
chmod +x /home/ec2-user/go-server

# Start the Go server
nohup /home/ec2-user/go-server > /home/ec2-user/server.log 2>&1 &