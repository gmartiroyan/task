locals {
  eks_subnet_ids     = concat(tolist(data.aws_subnets.public.ids), tolist(data.aws_subnets.private.ids))
  fargate_subnet_ids = length(var.fargate_subnet_ids) == 0 ? data.aws_subnets.private.ids : var.fargate_subnet_ids
}

locals {
  newrelic_values = [templatefile("${path.module}/templates/newrelic_values.yaml", {
  })]
}
