terraform {
  required_version = ">= v0.14.5"
  backend "s3" {
    region         = "eu-north-1"
    bucket         = "bwt-terraform-state-files"
    key            = "dev-usw2-eks-01/state.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.this_eks_id
}

provider "kubernetes" {
  host                   = module.eks.this_eks_endpoint
  cluster_ca_certificate = module.eks.this_eks_ca
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.this_eks_endpoint
    cluster_ca_certificate = module.eks.this_eks_ca
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
