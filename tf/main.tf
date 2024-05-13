
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
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
}
provider "aws" {
  region  = "eu-west-3"
  # profile = "default"

}

# resource "aws_instance" "instance_from_registry_sec_group" {
#   ami                    = "ami-00ac45f3035ff009e"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["sg-0c926a07123c11e43"]
#   tags = {
#     Name = "tf_simple_maven"
#   }
#     user_data = <<-EOF
#               #!/bin/bash
#                 sudo apt-get update
#                 sudo apt-get install docker.io -y
#                 sudo systemctl start docker
#                 sudo systemctl enable docker
#                 sudo usermod -a -G docker $(whoami)
#                 newgrp docker
#                 docker run -p 80:5000 -d ${var.container_image}
#               EOF
# }

resource "aws_eks_cluster" "example" {
  name     = "popo"
  role_arn = "arn:aws:iam::891377164650:role/EKSClusterRole"

  vpc_config {
    subnet_ids = ["subnet-0dc4e8cb069359a9b", "subnet-0f38494490a77c8c5 "]
  }
}


resource "aws_eks_node_group" "example" {
  depends_on = [
    aws_eks_cluster.example
  ]

  cluster_name    = "popo"
  node_group_name = "node-group"
  node_role_arn   = "arn:aws:iam::891377164650:role/EKSNodeRole"
  subnet_ids      = ["subnet-0dc4e8cb069359a9b", "subnet-0f38494490a77c8c5 "]
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }


  ami_type = "AL2_x86_64"
  instance_types = ["t3.small"]
}
