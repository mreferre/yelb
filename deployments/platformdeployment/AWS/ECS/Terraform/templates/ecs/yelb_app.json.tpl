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
         "name": "RACK_ENV",
         "value": "custom"
      },
      {
         "name": "YELB_APPSERVER_ENDPOINT",
         "value": "http://localhost:4567"
      },
      {
         "name": "REDIS_SERVER_ENDPOINT",
         "value": "localhost"
      },
      {
         "name": "YELB_DB_SERVER_ENDPOINT",
         "value": "localhost"
      }
    ],
    "portMappings": [${port_mappings}]
  }
