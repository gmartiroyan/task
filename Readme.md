# NodeJS Application on AWS EKS

This project demonstrates how to deploy a Node.js application on an AWS EKS cluster using Terraform for infrastructure provisioning, Docker for containerization, and Helm for managing Kubernetes manifests. The CI/CD pipeline is set up using GitHub Actions to automate the build, push, and deployment processes.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
    - [1. Infrastructure Provisioning](#1-infrastructure-provisioning)
    - [2. Application Containerization](#2-application-containerization)
    - [3. CI/CD Pipeline](#3-cicd-pipeline)
- [Usage](#usage)
- [License](#license)

## Overview

This project consists of:
- A Node.js application that runs on a Kubernetes cluster.
- Infrastructure resources (VPC and EKS) provisioned via Terraform.
- CI/CD pipeline that builds and deploys the application automatically on release creation.

## Architecture

- **Terraform**: Manages the AWS infrastructure (VPC, EKS).
- **Docker**: Containerizes the Node.js application.
- **Helm**: Manages Kubernetes manifests for deployment.
- **GitHub Actions**: Implements the CI/CD pipeline for continuous integration and deployment.

## Prerequisites

- AWS Account
- [Terraform](https://www.terraform.io/downloads.html)
- [Docker](https://docs.docker.com/get-docker/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [GitHub Account](https://github.com/)

## Setup

### 1. Infrastructure Provisioning

1. Navigate to the `terraform` directory in your project.
2. Configure your AWS credentials.
3. Run the following commands to provision the infrastructure:
   ```bash
   terraform init
   terraform plan
   terraform apply

3. Build and Push Docker Image
   Navigate to the directory containing the Dockerfile.
   Build the Docker image:
   ```bash
   docker build -t yourdockerhubusername/node-hostname:latest .
   Push the Docker image to your container registry (e.g., AWS ECR).