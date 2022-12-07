# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

data "template_file" "app_ui_name" {
  template = file("./templates/ecs/${var.app_name}_app.json.tpl")

  vars = {
#    app_image      = "${local.aws_account}.dkr.ecr.${local.aws_region}.amazonaws.com/${var.app_ui_name}:latest"
    app_image      = "mreferre/yelb-ui:0.10"
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu / 4
    fargate_memory = var.fargate_memory
    aws_region     = local.aws_region
    app_name       = var.app_ui_name
    log_group      = var.app_name
    domain_name    = "${var.app_name}.local"
    port_mappings  = "{ \"containerPort\": ${var.app_port},\"hostPort\": ${var.app_port} }"
  }
}

data "template_file" "app_server_name" {
  template = file("./templates/ecs/${var.app_name}_app.json.tpl")

  vars = {
#    app_image      = "${local.aws_account}.dkr.ecr.${local.aws_region}.amazonaws.com/${var.app_server_name}:latest"
    app_image      = "mreferre/yelb-appserver:0.7"
    fargate_cpu    = var.fargate_cpu / 4
    fargate_memory = var.fargate_memory
    aws_region     = local.aws_region
    app_name       = var.app_server_name
    log_group      = var.app_name
    domain_name    = "${var.app_name}.local"
    port_mappings  = ""
  }
}

data "template_file" "app_cache_name" {
  template = file("./templates/ecs/${var.app_name}_app.json.tpl")

  vars = {
    # app_image      = "${local.aws_account}.dkr.ecr.${local.aws_region}.amazonaws.com/${var.app_cache_name}:latest"
    app_image      = "redis:4.0.2"
    fargate_cpu    = var.fargate_cpu / 4
    fargate_memory = var.fargate_memory
    aws_region     = local.aws_region
    app_name       = var.app_cache_name
    log_group      = var.app_name
    domain_name    = "${var.app_name}.local"
    port_mappings  = ""
  }
}

data "template_file" "app_db_name" {
  template = file("./templates/ecs/${var.app_name}_app.json.tpl")

  vars = {
    # app_image      = "${local.aws_account}.dkr.ecr.${local.aws_region}.amazonaws.com/${var.app_db_name}:latest"
    app_image      = "mreferre/yelb-db:0.6"
    fargate_cpu    = var.fargate_cpu / 4
    fargate_memory = var.fargate_memory
    aws_region     = local.aws_region
    app_name       = var.app_db_name
    log_group      = var.app_name
    domain_name    = "${var.app_name}.local"
    port_mappings  = ""
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = format("[%s,%s,%s,%s]", 
    data.template_file.app_ui_name.rendered, 
    data.template_file.app_server_name.rendered,
    data.template_file.app_cache_name.rendered, 
    data.template_file.app_db_name.rendered)
}

resource "aws_ecs_service" "main" {
  name            = "${var.app_ui_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.yelb_ui.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.app_ui_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

