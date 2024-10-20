data "aws_availability_zones" "all" {
  all_availability_zones = true
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
