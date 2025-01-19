#!/bin/bash

# Download the Go server binary from S3
aws s3 cp s3://go-server-bucket/go-server /home/ec2-user/go-server

# Set permissions for the binary
chmod +x /home/ec2-user/go-server

# Start the Go server
nohup /home/ec2-user/go-server > /home/ec2-user/server.log 2>&1 &