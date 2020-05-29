This is a sample AWS Cloudformation template. One template allows you to deploy using both the EC2 and FARGATE launch types. This template is not optimized; there is a huge space for improvement (feedbacks are welcome). 

Please note that:
- I tested the `FARGATE` launch type in public subnets only (Fargate tasks require Internet access to pull images from Docker Hub) 
- If you choose `FARGATE` as a `LaunchType` you have to set `PublicIP` to `ENABLED`
- If you choose `EC2` as a `LaunchType` you have to set `PublicIP` to `DISABLED`
- This template uses `awsvpc` as the networking mode so make sure your EC2 instances (in the `EC2` launch type scenario) have enough ENIs.

These are two CLI examples that work in my environments. 

This deploys to FARGATE:

```
aws cloudformation create-stack --template-body file://./yelb-cloudformation-ECS-deployment.yaml --parameters ParameterKey=Cluster,ParameterValue="TestCluster" ParameterKey=VPC,ParameterValue="vpc-cfeafcb6" ParameterKey=PublicSubnetOne,ParameterValue="subnet-6a88e013" ParameterKey=PublicSubnetTwo,ParameterValue="subnet-6cc35627" ParameterKey=LaunchType,ParameterValue="FARGATE" ParameterKey=Domain,ParameterValue="yelb.local" ParameterKey=CountOfUiTasks,ParameterValue=2 ParameterKey=CountOfAppserverTasks,ParameterValue=3 ParameterKey=PublicIP,ParameterValue="ENABLED" --capabilities CAPABILITY_IAM --stack-name yelb-fargate --region us-west-2
```

This deploys to EC2:

```
aws cloudformation create-stack --template-body  file://./yelb-cloudformation-ECS-deployment.yaml --parameters ParameterKey=Cluster,ParameterValue="TestCluster" ParameterKey=VPC,ParameterValue="vpc-cfeafcb6" ParameterKey=PublicSubnetOne,ParameterValue="subnet-6a88e013" ParameterKey=PublicSubnetTwo,ParameterValue="subnet-6cc35627" ParameterKey=LaunchType,ParameterValue="EC2" ParameterKey=Domain,ParameterValue="yelb.local" ParameterKey=CountOfUiTasks,ParameterValue=2 ParameterKey=CountOfAppserverTasks,ParameterValue=3 ParameterKey=PublicIP,ParameterValue="DISABLED" --capabilities CAPABILITY_IAM --stack-name yelb-ec2 --region us-west-2
```
