provider "aws" {
  region  = "us-west-2"
  # profile = "terraform"

  # endpoints {
  #   dynamodb = "http://localhost:4566"  # for localstack
  # }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP access and SSH from my machine"

  ingress {
    description = "Allow HTTP from my machine"
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"] # Replace <YOUR_IP> with your machine's IP
  }

  ingress {
    description = "Allow SSH from my machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"] # Replace <YOUR_IP> with your machine's public IP
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_dynamodb_table" "demo_table" {
  name     = "demo_table"
  hash_key = "ID"

  attribute {
    name = "ID"
    type = "N"
  }

  billing_mode = "PAY_PER_REQUEST"
}

# resource "aws_iam_role" "ec2_role" {
#   name = "ec2-combined-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow"
#         Principal = { Service = "ec2.amazonaws.com" }
#         Action    = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "combined_policy" {
#   name        = "ec2-s3-dynamodb-policy"
#   description = "Policy for S3 and DynamoDB access"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       # S3 Permissions
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:GetBucketLocation"
#         ]
#         Resource = [
#           "${aws_s3_bucket.go_server_bucket.arn}",
#           "${aws_s3_bucket.go_server_bucket.arn}/*"
#         ]
#       },
#       # DynamoDB Permissions
#       {
#         Effect = "Allow"
#         Action = [
#           "dynamodb:PutItem",
#           "dynamodb:GetItem",
#           "dynamodb:Scan",
#           "dynamodb:Query"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_combined_policy" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.combined_policy.arn
# }

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "ec2-combined-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

resource "aws_instance" "go_server" {
  ami                  = "ami-093a4ad9a8cc370f4" # Replace with a valid Amazon Linux 2 AMI ID for your region
  instance_type        = "t2.micro"              # Free-tier eligible instance type
  # key_name             = aws_key_pair.go_server_key.key_name
  # iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  iam_instance_profile = "LabInstanceProfile"
  security_groups = [
    aws_security_group.allow_http_ssh.name
  ]

  depends_on = [
    # aws_iam_instance_profile.ec2_instance_profile,
    aws_security_group.allow_http_ssh
  ]

  user_data = <<-EOF
              #!/bin/bash
              BUCKET=${aws_s3_bucket.go_server_bucket.bucket}
              aws s3 cp s3://$BUCKET/init-script.sh /home/ec2-user/init-script.sh
              chmod +x /home/ec2-user/init-script.sh
              /home/ec2-user/init-script.sh $BUCKET
              EOF

  tags = {
    Name = "GoServerInstance"
  }
}

# resource "aws_key_pair" "go_server_key" {
#   key_name   = "go-server-key"
#   public_key = file("./example-key.pub")
# }

# Create an S3 bucket
resource "aws_s3_bucket" "go_server_bucket" {
  bucket = "go-server-bucket-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Upload Go binary
resource "aws_s3_object" "go_binary" {
  bucket = aws_s3_bucket.go_server_bucket.id
  key    = "go-server"
  source = "./server/go-server" # Path to your Go binary
  acl    = "private"
}

# Upload initialization script
resource "aws_s3_object" "init_script" {
  bucket = aws_s3_bucket.go_server_bucket.id
  key    = "init-script.sh"
  source = "./scripts/init-script.sh" # Path to your init script
  acl    = "private"
}

output "ec2_public_ip" {
  value       = aws_instance.go_server.public_ip
  description = "Public IP of the Go server"
}
