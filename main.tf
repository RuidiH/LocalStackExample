terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
}

provider "aws" {
  region     = "us-west-1"
  access_key = "mock"
  secret_key = "mock"

  endpoints {
    dynamodb = "http://localhost:4566"
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx-server"
  ports {
    internal = 80
    external = 8080
  }
}

resource "aws_dynamodb_table" "demo_table" {
  name         = "demo_table"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "N"
  }

  billing_mode = "PAY_PER_REQUEST"
}


