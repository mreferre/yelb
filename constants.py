import pathlib

YELB_PUBLIC_COMPONENSTS = {
    "Yelb-Ui": {
        "COMTAINER_PORT": 80,
        "SERVICE_DESIRED_COUNT": 2,
        "HEALTH_CHECK_PATH": "/",
        "HEALTH_CHECK_PORT": 80,
    },
}

YELB_PRIVATE_COMPONENSTS = {
    "Yelb-AppServer": {
        "COMTAINER_PORT": 4567,
        "SERVICE_DESIRED_COUNT": 2,
    },
    "Yelb-DB": {
        "COMTAINER_PORT": 5432,
        "SERVICE_DESIRED_COUNT": 1,
    },
    "Yelb-Redis": {
        "COMTAINER_PORT": 6379,
        "SERVICE_DESIRED_COUNT": 1,
    },
}

YELB_NAMESPACE_NAME = "yelb.local"
YELB_NAMESPACE_ARN_EXPORT_NAME = "yelb:NamepaceArn"
YELB_NAMESPACE_ID_EXPORT_NAME = "yelb:NamepaceId"
ALB_YELP_APPLICATION_PATH = "*"

ECS_CLUSTER_NAME_EXPORT_NAME = "prod:ClusterName"
ALB_PUBLIC_LISTENER_ARN_EXPORT_NAME = "prod:PublicListener"
ECS_CLUSTER_SECURITY_GROUP_ID_EXPORT_NAME = "prod:ContainerSecurityGroup"
ECS_CLUSTER_VPC_ID_EXPORT_NAME = "prod:VpcId"
ECS_CLUSTER_PRIVATE_SUBNET_ONE_EXPORT_NAME = "prod:PrivateSubnetOne"
ECS_CLUSTER_PRIVATE_SUBNET_TWO_EXPORT_NAME = "prod:PrivateSubnetTwo"
ECS_CLUSTER_PUBLIC_SUBNET_ONE_EXPORT_NAME = "prod:PublicSubnetOne"
ECS_CLUSTER_PUBLIC_SUBNET_TWO_EXPORT_NAME = "prod:PublicSubnetTwo"

# "./generated/"
YELB_COMPONENTS_CODE_DIRECTORY_PATH = str(
    pathlib.Path(__file__).parent.joinpath("generated").resolve()
)

# "./code_templates/"
YELB_CODE_TEMPLATES_DIRECTORY_PATH = str(
    pathlib.Path(__file__).parent.joinpath("code_templates").resolve()
)

TEMPLATE_SKELETON_DIRECTORY_NAME = "skeleton"
TEMPLATE_RUNTIMES_DIRECTORY_NAME = "runtimes"
TEMPLATE_CONSTANTS_FILE_NAME = "constants.py"
