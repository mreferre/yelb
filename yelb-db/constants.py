COMPONENT_NAME = "Yelb-DB"

ECS_CLUSTER_VPC_ID = "vpc-0ce1af33babd05955"
ECS_CLUSTER_SECURITY_GROUP_ID = "sg-02a78ac3859239ee6"
ECS_CLUSTER_ARN = "arn:aws:ecs:us-east-1:027179758433:cluster/prod"
ECS_CLUSTER_NAME = ECS_CLUSTER_ARN.split("/")[-1]

YELB_NAMESPACE_NAME = "yelb.local"
YELB_NAMESPACE_ARN = "arn:aws:servicediscovery:us-east-1:027179758433:namespace/ns-d2nx25jjg53oxa65"
YELB_NAMESPACE_ID = YELB_NAMESPACE_ARN.split("/")[-1]

ECR_REPOSITORY_NAME = COMPONENT_NAME.lower()

CONTAINER_MEMORY = 2048
CONTAINER_CPU = 512
COMTAINER_PORT = 5432
CONTAINER_ENVIRONMENT_SEARCH_DOMAIN_KEY = "SEARCH_DOMAIN"

SERVICE_NAME = COMPONENT_NAME.lower()
SERVICE_DESIRED_COUNT = 1
