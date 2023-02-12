from typing import Any

from aws_cdk import Duration
from aws_cdk import Fn
from aws_cdk import Stack
from aws_cdk import Stage
from aws_cdk import aws_ec2 as ec2
from aws_cdk import aws_ecr as ecr
from aws_cdk import aws_ecs as ecs
from aws_cdk import aws_elasticloadbalancingv2 as elbv2
from aws_cdk import aws_servicediscovery as servicediscovery
from constructs import Construct
from ecs_service.infrastructure import EcsService

import constants


class YelbComponent(Stage):
    def __init__(
        self,
        scope: Construct,
        id_: str,
        should_attach_to_public_alb: bool,
        **kwargs: Any,
    ) -> None:
        super().__init__(scope, id_, **kwargs)

        stack = Stack(self, constants.COMPONENT_NAME)

        self.ecr_repository = self.__create_ecr_repository(stack)

        self.ecs_cluster = self.__import_ecs_cluster(stack)
        self.yelb_namespace = self.__import_yelb_namespace(stack)

        self.ecs_service = EcsService(
            stack,
            f"{constants.COMPONENT_NAME}-Ecs-Service",
            ecr_repository=self.ecr_repository,
            ecs_cluster=self.ecs_cluster,
            yelb_namespace=self.yelb_namespace,
        )

        if should_attach_to_public_alb:
            self.__attach_service_to_alb_listener(stack, self.ecs_service.service)

    def __create_ecr_repository(self, stack: Stack) -> ecr.Repository:
        repository_logical_id = f"{constants.ECR_REPOSITORY_NAME}-Repository"

        repository = ecr.Repository(
            stack,
            repository_logical_id,
        )

        return repository

    def __import_yelb_namespace(
        self, stack: Stack
    ) -> servicediscovery.IPrivateDnsNamespace:
        yelb_namespace_logical_id = "Yelb-Namespace"

        namespace_arn = Fn.import_value(constants.YELB_NAMESPACE_ARN_EXPORT_NAME)
        namespace_id = Fn.import_value(constants.YELB_NAMESPACE_ID_EXPORT_NAME)

        namespace = (
            servicediscovery.PrivateDnsNamespace.from_private_dns_namespace_attributes(
                stack,
                yelb_namespace_logical_id,
                namespace_arn=namespace_arn,
                namespace_id=namespace_id,
                namespace_name=constants.YELB_NAMESPACE_NAME,
            )
        )

        return namespace

    def __import_ecs_cluster(self, stack: Stack) -> ecs.ICluster:
        ecs_cluster_logical_id = "Ecs-Cluster"

        availability_zones = list(
            map(lambda i: Fn.select(i, Fn.get_azs(self.region)), [0, 1])
        )
        vpc_id = Fn.import_value(constants.ECS_CLUSTER_VPC_ID_EXPORT_NAME)
        public_subnet_one_id = Fn.import_value(
            constants.ECS_CLUSTER_PUBLIC_SUBNET_ONE_EXPORT_NAME
        )
        public_subnet_two_id = Fn.import_value(
            constants.ECS_CLUSTER_PUBLIC_SUBNET_TWO_EXPORT_NAME
        )
        private_subnet_one_id = Fn.import_value(
            constants.ECS_CLUSTER_PRIVATE_SUBNET_ONE_EXPORT_NAME
        )
        private_subnet_two_id = Fn.import_value(
            constants.ECS_CLUSTER_PRIVATE_SUBNET_TWO_EXPORT_NAME
        )
        vpc = ec2.Vpc.from_vpc_attributes(
            stack,
            "Vpc",
            availability_zones=availability_zones,
            vpc_id=vpc_id,
            public_subnet_ids=[
                public_subnet_one_id,
                public_subnet_two_id,
            ],
            private_subnet_ids=[
                private_subnet_one_id,
                private_subnet_two_id,
            ],
        )

        security_group_id = Fn.import_value(
            constants.ECS_CLUSTER_SECURITY_GROUP_ID_EXPORT_NAME
        )
        security_group = ec2.SecurityGroup.from_security_group_id(
            stack,
            "Security-Group",
            security_group_id=security_group_id,
        )

        region = Stack.region
        account = Stack.account
        cluster_name = Fn.import_value(constants.ECS_CLUSTER_NAME_EXPORT_NAME)
        cluster_arn = f"arn:aws:ecs:{region}:{account}:cluster/{cluster_name}"

        ecs_cluster = ecs.Cluster.from_cluster_attributes(
            stack,
            ecs_cluster_logical_id,
            vpc=vpc,
            security_groups=[security_group],
            cluster_arn=cluster_arn,
            cluster_name=cluster_name,
        )

        return ecs_cluster

    def __attach_service_to_alb_listener(
        self, stack: Stack, service: ecs.Ec2Service
    ) -> None:
        availability_zones = list(
            map(lambda i: Fn.select(i, Fn.get_azs(self.region)), [0, 1])
        )
        vpc_id = Fn.import_value(constants.ECS_CLUSTER_VPC_ID_EXPORT_NAME)
        public_subnet_one_id = Fn.import_value(
            constants.ECS_CLUSTER_PUBLIC_SUBNET_ONE_EXPORT_NAME
        )
        public_subnet_two_id = Fn.import_value(
            constants.ECS_CLUSTER_PUBLIC_SUBNET_TWO_EXPORT_NAME
        )
        private_subnet_one_id = Fn.import_value(
            constants.ECS_CLUSTER_PRIVATE_SUBNET_ONE_EXPORT_NAME
        )
        private_subnet_two_id = Fn.import_value(
            constants.ECS_CLUSTER_PRIVATE_SUBNET_TWO_EXPORT_NAME
        )
        vpc = ec2.Vpc.from_vpc_attributes(
            stack,
            "Vpc",
            availability_zones=availability_zones,
            vpc_id=vpc_id,
            public_subnet_ids=[
                public_subnet_one_id,
                public_subnet_two_id,
            ],
            private_subnet_ids=[
                private_subnet_one_id,
                private_subnet_two_id,
            ],
        )

        listener_arn = Fn.import_value(constants.ALB_PUBLIC_LISTENER_ARN_EXPORT_NAME)
        alb_listener = elbv2.ApplicationListener.from_lookup(
            stack,
            "Alb-Listener",
            listener_arn=listener_arn,
        )

        health_check = elbv2.HealthCheck(
            protocol=elbv2.Protocol.HTTP,
            path=constants.HEALTH_CHECK_PATH,
            interval=Duration.seconds(6),
            timeout=Duration.seconds(5),
            healthy_threshold_count=2,
        )

        target_group = elbv2.ApplicationTargetGroup(
            stack,
            f"{constants.COMPONENT_NAME}-Target-Group",
            port=constants.COMTAINER_PORT,
            protocol=elbv2.ApplicationProtocol.HTTP,
            targets=[service],
            health_check=health_check,
            target_type=elbv2.TargetType.IP,
            vpc=vpc,
        )

        listener_rule = elbv2.ApplicationListenerRule(
            stack,
            f"{constants.COMPONENT_NAME}-Listener-Rule",
            listener=alb_listener,
            priority=10,
            conditions=[
                elbv2.ListenerCondition.path_patterns(
                    [constants.ALB_YELP_APPLICATION_PATH]
                )
            ],
            action=elbv2.ListenerAction.forward(target_groups=[target_group]),
        )
