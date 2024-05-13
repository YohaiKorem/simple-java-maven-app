
variable "container_image"{
    type = string
    default = "yohaikorem/maven_app:0.1.0"
}
terraform {
required_version = ">= 1.0.0"

backend "s3" {
    bucket = "yohai-tf-bucket"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
provider "aws" {
  region  = "eu-west-3"
  # profile = "default"

}

resource "aws_instance" "instance_from_registry_sec_group" {
  ami                    = "ami-00ac45f3035ff009e"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c926a07123c11e43"]
  tags = {
    Name = "tf_simple_maven"
  }
    user_data = <<-EOF
              #!/bin/bash
                sudo apt-get update
                sudo apt-get install docker.io -y
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -a -G docker $(whoami)
                newgrp docker
                docker run -p 80:5000 -d ${var.container_image}
              EOF
}

resource "eks_managed_node_groups" "cluster" {
one = {
    name = "node-group-1"

    instance_types = ["t3.small"]

    min_size     = 1
    max_size     = 3
    desired_size = 2
}
two = {
    name = "node-group-2"

    instance_types = ["t3.small"]

    min_size     = 1
    max_size     = 2
    desired_size = 1
}
}