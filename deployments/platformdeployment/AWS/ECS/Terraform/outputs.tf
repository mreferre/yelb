# outputs.tf

output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "user" {
  value = local.aws_account
}

output "region" {
  value = local.aws_region
}


