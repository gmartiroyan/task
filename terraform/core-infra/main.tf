module "vpc" {
  source = "../modules/vpc"

  name = "dev"

  cidr            = var.vpc_cidr
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
  depends_on      = [module.vpc]
  source          = "../modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_name        = module.vpc.name
  subnets         = module.vpc.public_subnet_ids

/**fargate_profiles = [
    "kube-system",
    "dev-bwt"
  ]
*/
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
