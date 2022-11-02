  {
    "name": "${app_name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${log_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${app_name}"
        }
    },
    "environment": [
      {
         "name": "SEARCH_DOMAIN",
         "value": "${domain_name}"
      },
      {
         "name": "APPSERVER_HOST",
         "value": "localhost"
      },
      {
         "name": "CACHE_HOST",
         "value": "localhost"
      },
      {
         "name": "DB_HOST",
         "value": "localhost"
      }
    ],
    "portMappings": [${port_mappings}]
  }
