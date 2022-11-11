# variables.tf

#locals "aws_region" {
#  description = "The AWS region things are created in"
#  aws_region  = "eu-central-1"
#}

locals {
    aws_account = data.aws_caller_identity.current.account_id
    aws_region = data.aws_region.current.name
}

#variable "aws_account" {
#  description = "The AWS account terraform has access to"
#  default     = ${data.aws_caller_identity.current.account_id}
#}

# General app name
variable "app_name" {
  description = "Application name"
  default     = "yelb"
}

# Container names
variable "app_ui_name" {
  description = "UI container name"
  default     = "yelb-ui"
}

variable "app_server_name" {
  description = "Backend container name"
  default     = "yelb-appserver"
}

variable "app_cache_name" {
  description = "Cache container name"
  default     = "redis-server"
}

variable "app_db_name" {
  description = "Database container name"
  default     = "yelb-db"
}

variable "cidr_subnet" {
  description = "cidr subnet for the project"
  default = "172.17.0.0/16"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

#variable "app_image" {
#  description = "Docker image to run in the ECS cluster"
#  default     = "${var.account}.dkr.ecr.${aws_region}.amazonaws.com/project:latest"
#}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "repository_policy" {
  description = "ECR policy"
  default =  <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the yelb repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
  }
  variable "task_policy" {
    description = "Role to allow ECS exec connection for interactive shell"
    default =  <<EOF
      {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                  "ecr:GetAuthorizationToken",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:BatchGetImage",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "ssmmessages:CreateControlChannel",
                  "ssmmessages:CreateDataChannel",
                  "ssmmessages:OpenControlChannel",
                  "ssmmessages:OpenDataChannel",
                  "ssmmessages:CreateControlChannel",
                  "route53:CreateHostedZone",
                  "route53:UpdateHostedZoneComment",
                  "route53:GetHostedZone",
                  "route53:ListHostedZones",
                  "route53:DeleteHostedZone",
                  "route53:ChangeResourceRecordSets",
                  "route53:ListResourceRecordSets",
                  "route53:GetHostedZoneCount",
                  "route53:ListHostedZonesByName"
            ]
          }
        ]
      }    
      EOF
  }
  

