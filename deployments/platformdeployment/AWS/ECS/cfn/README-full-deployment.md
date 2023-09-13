The file [yelb-cloudformation-ECS-deployment-with-prereqs.yaml](./yelb-cloudformation-ECS-deployment-with-prereqs.yaml) is a variation of the original CFN template provided in the public repo.

This plan supports FARGATE only, but adds the VPC, ECS Cluster, and associated prerequisites. If the candidate chooses to revise the original CFN template to create these prereqs, then the interviewer can use this example to validate and potentially guide the candidate.

The network prerequisites are defined based on this [reference document]
(https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html).

A sample command to deploy this stack is:

```bash
aws cloudformation create-stack --template-body file://./yelb-cloudformation-ECS-deployment-with-prereqs.yaml --parameters ParameterKey=EnvironmentName,ParameterValue='yelb-ck-example-01' ParameterKey=LaunchType,ParameterValue="FARGATE" ParameterKey=Domain,ParameterValue="ck-example-yelb.local" --capabilities CAPABILITY_IAM --region us-west-2 --stack-name ck-example-yelb-fargate-01
```

To view the output, particularly the URL of the deployed application, you can show the stack output as follows:

```bash
aws cloudformation describe-stacks --stack-name ck-example-yelb-fargate-01 --query "Stacks[].Outputs" --region us-west-2
```
