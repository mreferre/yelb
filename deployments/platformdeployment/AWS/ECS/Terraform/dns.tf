/* not needed in awsvpc networking mode when localhost is used
resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${var.app_name}.local"
  description = "Yelb service nameserver"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "ns-records" {
  for_each = toset( [var.app_ui_name, var.app_server_name, var.app_db_name, var.app_cache_name] )

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.app.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

*/