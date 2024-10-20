terraform {
  required_version = ">= 0.14.5"

  required_providers {
    aws = ">= 3.19.0"
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
  }
}