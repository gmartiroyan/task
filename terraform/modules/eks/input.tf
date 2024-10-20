variable "cluster_name" {
  type        = string
  description = "Name to be used on all the resources as identifier string default"
}

variable "cluster_version" {
  type        = string
  default     = "1.20"
  description = "EKS version to deploy"
}

variable "vpc_name" {
  type        = string
  description = "The VPC name where EKS cluster will be deployed"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Specifies whether cluster endpoint will be accessible from private subnets"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Specifies whether cluster endpoint will be accessible from public subnets"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR from where cluster endpoint will be accessible"
}

variable "cluster_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to put on cluster"
}

variable "fargate_subnet_ids" {
  type    = list(any)
  default = []
}

variable "local_exec_interpreter" {
  type        = list(string)
  default     = ["/bin/sh", "-c"]
  description = "Shell to use for local_exec"
}

variable "wait_for_cluster_command" {
  type        = string
  default     = "curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"
  description = "`local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT`"
}

variable "node_groups" {
  type = any
  default = {
    ng-default = {
      name             = "ng-default"
      subnet_ids       = []
      desired_capacity = 4
      max_size         = 6
      min_size         = 2
      disk_size        = 20
      capacity_type    = "ON_DEMAND"
      instance_type    = ["m5.large"]
      remote_access    = false
    }
  }
  description = "The list of maps of NodeGroups"
}

variable "max_size" {
  description = "Maximum number of nodes permitted for autoscaling"
  type        = number
  default     = 6
}

variable "min_size" {
  description = "Minimum number of nodes permitted in autoscaling group"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of nodes in autoscaling group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type to use in autoscaling group"
  type        = string
  default     = "m5.large"
}


variable "subnets" {
  description = "List of subnet IDs used by autoscale group"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "file_server_bucket_arn" {
  type        = string
  default     = ""
  description = "Arn of the file server S3 bucket to grant access for eks nodes"
}


variable "nginx_replica_count" {
  type        = string
  default     = "2"
  description = "The number of replicas of the Ingress controller deployment"
}

variable "newrelic_licensekey" {
  type    = string
  default = ""
}

variable "fargate_profiles" {
  type = list(string)
  default = [
    "kube-system"
  ]
}
