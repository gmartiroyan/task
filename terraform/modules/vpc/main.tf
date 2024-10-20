/**
 * # Terraform Module for VPC
 *
 * ## Description
 *
 * The module for creating/managing VPC with all required subnets, routes, NACLs etc...
 *
 * ## Usage
 *
 * ```hcl
 * module "vpc" {
 * source = "../modules/vpc"
 * name = "vpc"
 *
 * cidr = "10.9.0.0/16"
 * private_subnets = ["10.9.0.0/24", "10.9.1.0/24"]
 * public_subnets = ["10.9.2.0/24", "10.9.3.0/24"]
 * }
 * ```
*/


######
# VPC
######
resource "aws_vpc" "this" {

  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of Private subnets
#################
resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
  )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

#################
# Intra routes
#################
resource "aws_route_table" "intra" {
  count = length(var.intra_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.intra_subnet_suffix}"
    },
    var.tags,
  )
}

#################
# External routes
#################
resource "aws_route_table" "external" {
  count = length(var.external_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-${var.external_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_route" "external_internet_gateway" {
  count                  = length(var.external_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.external[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone_id    = element(sort(data.aws_availability_zones.all.zone_ids), count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id               = aws_vpc.this.id
  cidr_block           = var.private_subnets[count.index]
  availability_zone_id = element(sort(data.aws_availability_zones.all.zone_ids), count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

#####################################################
# Intra subnets - private subnets without NAT gateway
#####################################################
resource "aws_subnet" "intra" {
  count = length(var.intra_subnets)

  vpc_id               = aws_vpc.this.id
  cidr_block           = var.intra_subnets[count.index]
  availability_zone_id = element(sort(data.aws_availability_zones.all.zone_ids), count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.intra_subnet_suffix}-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.intra_subnet_tags,
  )
}

##################
# External subnets
##################
resource "aws_subnet" "external" {
  count = length(var.external_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.external_subnets[count.index]
  availability_zone_id    = element(sort(data.aws_availability_zones.all.zone_ids), count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "%s-${var.external_subnet_suffix}-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.external_subnet_tags,
  )
}

##############
# NAT Gateway
##############

resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = length(var.private_subnets)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(data.aws_availability_zones.all.names, count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.private_subnets)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "intra" {
  count = length(var.intra_subnets)

  subnet_id      = element(aws_subnet.intra.*.id, count.index)
  route_table_id = element(aws_route_table.intra.*.id, 0)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "external" {
  count = length(var.external_subnets)

  subnet_id      = element(aws_subnet.external.*.id, count.index)
  route_table_id = element(aws_route_table.external.*.id, count.index)
}
