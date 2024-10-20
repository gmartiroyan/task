output "azs" {
  value = data.aws_availability_zones.all.names
}

output "public_subnet_ids" {
  value = tolist(aws_subnet.public.*.id)
}

output "private_subnet_ids" {
  value = tolist(aws_subnet.private.*.id)
}

output "name" {
  value = var.name
}

output "id" {
  value = aws_vpc.this.id
}
