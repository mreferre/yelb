In this folder there are Cloudformation, Copilot and CDK artifacts to deploy Yelb on Amazon ECS.

The CFN template(s) allows to deploy on both Amazon EC2 as well as AWS Fargate on existing cluster and VPCs. 

The CDK code and the Copilot manifests allow to deploy on AWS Fargate only and they create a dedicated ECS cluster and VPC. 

They are provided as basic examples of how to deploy Yelb on ECS. 

This is a visual representation of the ECS/EC2 deployment: 

![yelb-ecs-ec2](../../../../images/yelb-ecs-ec2.png) 

This is a visual representation of the ECS/Fargate deployment: 

![yelb-ecs-fargate](../../../../images/yelb-ecs-fargate.png) 
