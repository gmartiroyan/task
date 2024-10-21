# Node.js Application Deployment on AWS EKS with Helm and GitHub Actions

This project demonstrates the deployment of a Node.js application in an AWS EKS (Elastic Kubernetes Service) cluster. The application is containerized using Docker, and deployment is automated using Helm charts and a CI/CD pipeline through GitHub Actions. The infrastructure for Kubernetes, including networking and cluster setup, is provisioned using Terraform.

## Project Overview

This repository contains:
- **Terraform configuration** to provision the AWS infrastructure, including the EKS cluster.
- **Dockerfile** for the Node.js application.
- **Helm charts** for managing Kubernetes manifests and deploying the application in an atomic way.
- **GitHub Actions CI/CD pipeline** to automate Docker image building, tagging, and application deployment on new GitHub release creation.

The application is deployed using semantic versioning, where each release creates a new Docker image tagged with the release version. In case of failures during deployment, Helm’s atomic installation ensures that the cluster reverts to the previous stable state, and rollbacks are easily handled by rerunning the CI job with an older release tag.

## Table of Contents
- [Pre-requisites](#pre-requisites)
- [Infrastructure Setup with Terraform](#infrastructure-setup-with-terraform)
- [Application Deployment](#application-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Helm Chart Usage](#helm-chart-usage)
- [Accessing the Application](#accessing-the-application)
- [Rollback Mechanism](#rollback-mechanism)

## Pre-requisites

Before you begin, ensure you have the following installed on your local machine or CI/CD environment:

- [Terraform](https://www.terraform.io/downloads.html) - For infrastructure provisioning.
- [AWS CLI](https://aws.amazon.com/cli/) - To interact with AWS services.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - For interacting with the Kubernetes cluster.
- [Helm](https://helm.sh/docs/intro/install/) - For deploying and managing the Kubernetes application.
- [Docker](https://docs.docker.com/get-docker/) - For containerizing the Node.js application.

## Infrastructure Setup with Terraform

The Kubernetes infrastructure is deployed in AWS using Terraform. This includes VPC, subnets, and an EKS cluster. For more instruction see Readme files in terraform folders.

1. Navigate to the `terraform/core-infra` directory.
2. Configure your AWS credentials.
3. Run the following commands:
   ```bash
   terraform init
   terraform plan
   terraform apply

This will prompt for confirmation. After confirming, Terraform will deploy the AWS infrastructure.

4. Once the infrastructure is provisioned, configure kubectl to interact with the new EKS cluster: 
   ```
   aws eks --region <region-name> update-kubeconfig --name <eks-cluster-name>
   ```
## Application Deployment
### Dockerfile
A Dockerfile is provided to containerize the Node.js application. It defines how the application is packaged into a Docker image.

### Building and Pushing Docker Image
The GitHub Actions pipeline handles building and pushing the Docker image to AWS ECR. The image is tagged using the release version (following semantic versioning).

### Helm Charts
The Kubernetes application manifests are managed with Helm. Helm allows for flexible and atomic deployments.

### Helm Deployment
Helm is used for deploying the application in an atomic way, ensuring that failed deployments do not break the currently running version.

### CI/CD Pipeline
The GitHub Actions pipeline automates the following tasks on creating a new GitHub release:

- Build the Docker image from the Dockerfile.
- Tag the Docker image using the release version (semantic versioning).
- Push the image to AWS ECR.
- Deploy the application to the EKS cluster using Helm.

### Workflow File
The GitHub Actions workflow file is located in `.github/workflows/deploy-node-hostname.yaml`. It defines the CI/CD pipeline, triggered on every new release on `main` branch.

### Rollback Support
If you need to rollback to a previous release version, simply rerun the CI/CD job using the previous version tag. Helm will automatically revert the deployment to the specified version.

## Helm Chart Usage
### Install the Application:
    helm upgrade --install --atomic  node-hostname ./node-hostname/helm/
### Values.yaml Example
The following parameters can be customized in the values.yaml file:

- Docker image repository and tag.
- Application replica count.
- Kubernetes service type (NodePort, LoadBalancer).
- Ingress configurations.
- Resource requests and limits
## Accessing the Application
The application is exposed using an AWS Load Balancer (ALB/NLB), and its public DNS name can be used to access the app.
### How to Access:
1. Once deployed, retrieve the Load Balancer's public DNS:
   ```bash
   kubectl get ingress -o wide
   NAME            CLASS    HOSTS   ADDRESS                                                                   PORTS   AGE
   node-hostname   <none>   *       k8s-default-nodehost-5858963695-1374566640.eu-north-1.elb.amazonaws.com   80      46h
   ```
2. Navigate to the Load Balancer's DNS name in your browser.
### Enabling HTTPS
Optionally, HTTPS can be configured AWS ACM with a custom domain for public SSL certificates.

## Managing Secrets with GitHub Secrets
Sensitive information such as AWS credentials and other environment-specific data is managed securely using GitHub Secrets. GitHub Secrets ensure that no sensitive data is hard-coded in the repository.