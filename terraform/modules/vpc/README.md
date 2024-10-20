# Terraform Module for VPC

## Description

The module for creating/managing VPC with all required subnets, routes, NACLs etc...

## Usage

```hcl
module "vpc" {
source = "../modules/vpc"
name = "vpc"

cidr = "10.9.0.0/16"
private_subnets = ["10.9.0.0/24", "10.9.1.0/24"]
public_subnets = ["10.9.2.0/24", "10.9.3.0/24"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.external_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.external_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.intra_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.intra_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.external_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_external_inbound_acl_rules"></a> [external\_inbound\_acl\_rules](#input\_external\_inbound\_acl\_rules) | External subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_external_outbound_acl_rules"></a> [external\_outbound\_acl\_rules](#input\_external\_outbound\_acl\_rules) | External subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_external_subnet_suffix"></a> [external\_subnet\_suffix](#input\_external\_subnet\_suffix) | Suffix to append to external subnets name | `string` | `"external"` | no |
| <a name="input_external_subnet_tags"></a> [external\_subnet\_tags](#input\_external\_subnet\_tags) | Additional tags for the intra subnets | `map(string)` | <pre>{<br>  "tier": "external"<br>}</pre> | no |
| <a name="input_external_subnets"></a> [external\_subnets](#input\_external\_subnets) | A list of external subnets | `list(string)` | `[]` | no |
| <a name="input_intra_inbound_acl_rules"></a> [intra\_inbound\_acl\_rules](#input\_intra\_inbound\_acl\_rules) | Intra subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_intra_outbound_acl_rules"></a> [intra\_outbound\_acl\_rules](#input\_intra\_outbound\_acl\_rules) | Intra subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_intra_subnet_suffix"></a> [intra\_subnet\_suffix](#input\_intra\_subnet\_suffix) | Suffix to append to intra subnets name | `string` | `"intra"` | no |
| <a name="input_intra_subnet_tags"></a> [intra\_subnet\_tags](#input\_intra\_subnet\_tags) | Additional tags for the intra subnets | `map(string)` | <pre>{<br>  "tier": "intra"<br>}</pre> | no |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnets | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | n/a | yes |
| <a name="input_nat_eip_tags"></a> [nat\_eip\_tags](#input\_nat\_eip\_tags) | Additional tags for the NAT EIP | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateways | `map(string)` | `{}` | no |
| <a name="input_private_inbound_acl_rules"></a> [private\_inbound\_acl\_rules](#input\_private\_inbound\_acl\_rules) | Private subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_outbound_acl_rules"></a> [private\_outbound\_acl\_rules](#input\_private\_outbound\_acl\_rules) | Private subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_subnet_suffix"></a> [private\_subnet\_suffix](#input\_private\_subnet\_suffix) | Suffix to append to private subnets name | `string` | `"private"` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional tags for the private subnets | `map(string)` | <pre>{<br>  "tier": "private"<br>}</pre> | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | n/a | yes |
| <a name="input_public_inbound_acl_rules"></a> [public\_inbound\_acl\_rules](#input\_public\_inbound\_acl\_rules) | Public subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_public_outbound_acl_rules"></a> [public\_outbound\_acl\_rules](#input\_public\_outbound\_acl\_rules) | Public subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | Suffix to append to public subnets name | `string` | `"public"` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional tags for the public subnets | `map(string)` | <pre>{<br>  "tier": "public"<br>}</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |

## Testing

As this module can't be tested directly, you will need to manually modify a consuming repo to refer to your branch or path.

For example:

`source = "git::https://link-to-git-repository?ref=<my-dev-branch>"` or `source = "../modules/vpc"`
