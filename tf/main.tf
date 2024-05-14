variable "container_image" {
  type    = string
  default = "yohaikorem/maven_app:0.1.0"
}

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket  = "yohai-tf-bucket"
    key     = "global/s3/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_iam_role" "eks_node_group_role" {
  count = length([for role in data.aws_iam_role.existing_eks_node_group_role : role.id]) == 0 ? 1 : 0
  name  = "EKSNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  count      = length([for role in data.aws_iam_role.existing_eks_node_group_role : role.id]) == 0 ? 1 : 0
  role       = "EKSNodeRole"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  count      = length([for role in data.aws_iam_role.existing_eks_node_group_role : role.id]) == 0 ? 1 : 0
  role       = "EKSNodeRole"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  count      = length([for role in data.aws_iam_role.existing_eks_node_group_role : role.id]) == 0 ? 1 : 0
  role       = "EKSNodeRole"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "example" {
  name     = "popo"
  role_arn = "arn:aws:iam::891377164650:role/AWSServiceRoleForAmazonEKS"

  vpc_config {
    subnet_ids = ["subnet-0dc4e8cb069359a9b", "subnet-0f38494490a77c8c5"]
  }
}

resource "aws_eks_node_group" "example" {
  depends_on = [
    aws_eks_cluster.example,
    aws_iam_role.eks_node_group_role,
    aws_iam_role_policy_attachment.eks_node_group_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly
  ]

  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "node-group"
  node_role_arn   = local.eks_node_group_role_arn
  subnet_ids      = ["subnet-0dc4e8cb069359a9b", "subnet-0f38494490a77c8c5"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.small"]
}

data "aws_iam_role" "existing_eks_node_group_role" {
  count = 1
  name  = "EKSNodeRole"
}

locals {
  eks_node_group_role_arn = length([for role in data.aws_iam_role.existing_eks_node_group_role : role.id]) == 0 ? aws_iam_role.eks_node_group_role.arn : data.aws_iam_role.existing_eks_node_group_role.arn
}
