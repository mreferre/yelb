# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
/*
data "aws_iam_policy" "ecs_route53_role" {
   name ="Allow ecs exec and route53 access"

   policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ssmmessages:CreateControlChannel",
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
                  "route53:ListHostedZonesByName"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
*/
# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

#resource "aws_iam_role" "ecs_route53_role" {
#  name               = "myRoute53role"
#  assume_role_policy = var.task_policy
#}

 #for_each = toset([
#    aws_iam_policy.my_first_policy.arn,
#    aws_iam_policy.my_other_policy.arn,

     # Works with AWS Provided policies too!
#    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#  ])
  
#  role       = aws_iam_role.my_role.name
#  policy_arn = each.value


# ECS task execution role policy attachment
/*resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  for_each = toset(
    ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"#,
#      data.aws_iam_policy.ecs_route53_role.arn
    ])

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}*/

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


