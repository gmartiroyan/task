# Terraform Module for EKS

## Description
The module for creating/managing [AWS EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html), EKS Node Groups, IAM Roles and Policies for Kubernetes Service Account mappings

## Usage:

```hcl
data "aws_eks_cluster_auth" "this" {
  name = module.eks.this_eks_id
}

variable "cluster_name" {
  type    = string
  default = "bwt-eks"
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

module "vpc" {
  source = "../modules/vpc"
  name   = "main-vpc"

  cidr = "10.0.0.0/16"
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    "tier"                                      = "private"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
    "tier"                                      = "public"
  }

}

module "eks" {
  depends_on          = [module.vpc]
  source              = "../modules/eks"
  cluster_name        = var.cluster_name
  vpc_name            = module.vpc.name
  cluster_kms_key_arn = "arn:aws:kms:eu-north-1:111222333444:key/a1a2a3a4-b12b-c12c-d12d-e1e2e3e4e5e6"

  node_groups = {
    ng-default = {
      name             = "ng-default"
      subnet_ids       = module.vpc.public_subnet_ids
      desired_capacity = 4
      max_size         = 6
      min_size         = 2
      instance_type    = "m5.large"
      disk_size        = 20
      capacity_type    = "ON_DEMAND"
      remote_access    = true
      ng_tags          = {
        "ng-type" = "default"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.64.2 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.6.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.eks_cluster_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.AWSIdentityOICD](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.AmazonEKSAutoscalerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.AWSRoleForEKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.AWSRoleForEKSNodeGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.AmazonEKSAutoscalerRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSAutoscalerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.this_eks_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_key_pair.this_eks_ng_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.allow_ng_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_elb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.newrelic](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.node_termination_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_stack](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [null_resource.wait_for_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.this_local](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_iam_policy_document.this_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_eks_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_eks_autoscaler_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_eks_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [tls_certificate.this_eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Specifies whether cluster endpoint will be accessible from private subnets | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Specifies whether cluster endpoint will be accessible from public subnets | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | CIDR from where cluster endpoint will be accessible | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name to be used on all the resources as identifier string default | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to put on cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | EKS version to deploy | `string` | `"1.20"` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number of nodes in autoscaling group | `number` | `2` | no |
| <a name="input_eks_autoscaler_force_update"></a> [eks\_autoscaler\_force\_update](#input\_eks\_autoscaler\_force\_update) | This will force helm uninstall/install if true | `bool` | `false` | no |
| <a name="input_eks_autoscaler_ns"></a> [eks\_autoscaler\_ns](#input\_eks\_autoscaler\_ns) | The namespace where cluster autoscaler will be deployed | `string` | `"cluster-autoscaler"` | no |
| <a name="input_eks_autoscaler_service_account"></a> [eks\_autoscaler\_service\_account](#input\_eks\_autoscaler\_service\_account) | Service account in EKS for cluster autoscaler | `string` | `"cluster-autoscaler"` | no |
| <a name="input_eks_autoscaler_version"></a> [eks\_autoscaler\_version](#input\_eks\_autoscaler\_version) | Force Autoscaler update through delete/recreate if needed | `string` | `"9.4.0"` | no |
| <a name="input_file_server_bucket_arn"></a> [file\_server\_bucket\_arn](#input\_file\_server\_bucket\_arn) | Arn of the file server S3 bucket to grant access for eks nodes | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use in autoscaling group | `string` | `"m5.large"` | no |
| <a name="input_local_exec_interpreter"></a> [local\_exec\_interpreter](#input\_local\_exec\_interpreter) | Shell to use for local\_exec | `list(string)` | <pre>[<br>  "/bin/sh",<br>  "-c"<br>]</pre> | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of nodes permitted for autoscaling | `number` | `6` | no |
| <a name="input_metrics_server_force_update"></a> [metrics\_server\_force\_update](#input\_metrics\_server\_force\_update) | n/a | `bool` | `false` | no |
| <a name="input_metrics_server_namespace"></a> [metrics\_server\_namespace](#input\_metrics\_server\_namespace) | n/a | `string` | `"kube-system"` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of nodes permitted in autoscaling group | `number` | `2` | no |
| <a name="input_newrelic_licensekey"></a> [newrelic\_licensekey](#input\_newrelic\_licensekey) | n/a | `string` | `""` | no |
| <a name="input_nginx_ingress_certificate_arn"></a> [nginx\_ingress\_certificate\_arn](#input\_nginx\_ingress\_certificate\_arn) | n/a | `string` | `""` | no |
| <a name="input_nginx_ingress_namespace"></a> [nginx\_ingress\_namespace](#input\_nginx\_ingress\_namespace) | n/a | `string` | `"ingress-nginx"` | no |
| <a name="input_nginx_ingress_update"></a> [nginx\_ingress\_update](#input\_nginx\_ingress\_update) | This will force helm uninstall/install if true for Nginx ingress | `bool` | `false` | no |
| <a name="input_nginx_ingress_version"></a> [nginx\_ingress\_version](#input\_nginx\_ingress\_version) | The version of helm chart for Nginx ingress | `string` | `"4.1.2"` | no |
| <a name="input_nginx_nodeselector_enable"></a> [nginx\_nodeselector\_enable](#input\_nginx\_nodeselector\_enable) | n/a | `bool` | `false` | no |
| <a name="input_nginx_replica_count"></a> [nginx\_replica\_count](#input\_nginx\_replica\_count) | The number of replicas of the Ingress controller deployment | `string` | `"2"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | The list of maps of NodeGroups | `any` | <pre>{<br>  "ng-default": {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_capacity": 4,<br>    "disk_size": 20,<br>    "instance_type": [<br>      "m5.large"<br>    ],<br>    "max_size": 6,<br>    "min_size": 2,<br>    "name": "ng-default",<br>    "remote_access": false,<br>    "subnet_ids": []<br>  }<br>}</pre> | no |
| <a name="input_node_termination_handler_ns"></a> [node\_termination\_handler\_ns](#input\_node\_termination\_handler\_ns) | EKS Namespace where AWS Node Termination Handler will be deployed | `string` | `"aws-node-termination-handler"` | no |
| <a name="input_node_termination_handler_upgrade"></a> [node\_termination\_handler\_upgrade](#input\_node\_termination\_handler\_upgrade) | Force AWS Node Termination Handler update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_node_termination_handler_version"></a> [node\_termination\_handler\_version](#input\_node\_termination\_handler\_version) | Version number for AWS Node Termination Handler | `string` | `"0.15.0"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs used by autoscale group | `list(string)` | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The VPC name where EKS cluster will be deployed | `string` | n/a | yes |
| <a name="input_wait_for_cluster_command"></a> [wait\_for\_cluster\_command](#input\_wait\_for\_cluster\_command) | `local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT` | `string` | `"curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity-oidc-issuer"></a> [identity-oidc-issuer](#output\_identity-oidc-issuer) | n/a |
| <a name="output_this_eks_ca"></a> [this\_eks\_ca](#output\_this\_eks\_ca) | n/a |
| <a name="output_this_eks_endpoint"></a> [this\_eks\_endpoint](#output\_this\_eks\_endpoint) | n/a |
| <a name="output_this_eks_id"></a> [this\_eks\_id](#output\_this\_eks\_id) | n/a |

## Testing

As this module can't be tested directly, you will need to manually modify a consuming repo to refer to your branch or path.

For example:

`source = "git::https://link-to-git-repository?ref=<my-dev-branch>"` or `source = "../modules/eks"`
