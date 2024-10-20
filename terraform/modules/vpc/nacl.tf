########################
# Public Network ACLs
########################
resource "aws_network_acl" "public" {

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", var.cidr)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", var.cidr)
}

#######################
# Private Network ACLs
#######################
resource "aws_network_acl" "private" {

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress      = false
  rule_number = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", var.cidr)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", var.cidr)
}

########################
# Intra Network ACLs
########################
resource "aws_network_acl" "intra" {

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.intra.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.intra_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_network_acl_rule" "intra_inbound" {
  count = length(var.intra_inbound_acl_rules)

  network_acl_id = aws_network_acl.intra.id

  egress      = false
  rule_number = var.intra_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.intra_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.intra_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.intra_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.intra_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.intra_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.intra_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.intra_inbound_acl_rules[count.index], "cidr_block", var.cidr)
}

resource "aws_network_acl_rule" "intra_outbound" {
  count = length(var.intra_outbound_acl_rules)

  network_acl_id = aws_network_acl.intra.id

  egress      = true
  rule_number = var.intra_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.intra_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.intra_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.intra_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.intra_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.intra_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.intra_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.intra_outbound_acl_rules[count.index], "cidr_block", var.cidr)
}

#######################
# External Network ACLs
#######################
resource "aws_network_acl" "external" {

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.external.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.external_subnet_suffix}", var.name)
    },
    var.tags,
  )
}

resource "aws_network_acl_rule" "external_inbound" {
  count = length(var.external_inbound_acl_rules)

  network_acl_id = aws_network_acl.external.id

  egress      = false
  rule_number = var.external_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.external_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.external_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.external_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.external_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.external_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.external_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.external_inbound_acl_rules[count.index], "cidr_block", var.cidr)
}

resource "aws_network_acl_rule" "external_outbound" {
  count = length(var.external_outbound_acl_rules)

  network_acl_id = aws_network_acl.external.id

  egress      = true
  rule_number = var.external_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.external_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.external_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.external_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.external_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.external_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.external_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.external_outbound_acl_rules[count.index], "cidr_block", var.cidr)
}