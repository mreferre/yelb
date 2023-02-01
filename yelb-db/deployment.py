from typing import Any

from aws_cdk import RemovalPolicy
from aws_cdk import Stack
from aws_cdk import aws_ec2 as ec2
from aws_cdk import aws_ecr as ecr
from aws_cdk import aws_ecs as ecs
from aws_cdk import aws_servicediscovery as servicediscovery
from constructs import Construct

import constants
from ecs_service.infrastructure import EcsService


class YelbDBInfrastructure(Stack):
    def __init__(self, scope: Construct, id_: str, **kwargs: Any) -> None:
        super().__init__(scope, id_, **kwargs)

        self.ecr_repository = self.__create_ecr_repository()

        self.ecs_cluster = self.__get_ecs_cluster()
        self.yelb_namespace = self.__get_yelb_namespace()

        self.ecs_service = EcsService(
            self,
            f"{constants.COMPONENT_NAME}-Ecs-Service",
            ecr_repository=self.ecr_repository,
            ecs_cluster=self.ecs_cluster,
            yelb_namespace=self.yelb_namespace,
        )

    def __create_ecr_repository(self) -> ecr.Repository:
        repository_logical_id = f"{constants.ECR_REPOSITORY_NAME}-Repository"

        repository = ecr.Repository(
            self,
            repository_logical_id,
        )

        return repository

    def __get_yelb_namespace(self) -> servicediscovery.IPrivateDnsNamespace:
        yelb_namespace_logical_id = "Yelb-Namespace"

        namespace = (
            servicediscovery.PrivateDnsNamespace.from_private_dns_namespace_attributes(
                self,
                yelb_namespace_logical_id,
                namespace_arn=constants.YELB_NAMESPACE_ARN,
                namespace_id=constants.YELB_NAMESPACE_ID,
                namespace_name=constants.YELB_NAMESPACE_NAME,
            )
        )

        return namespace

    def __get_ecs_cluster(self) -> ecs.ICluster:
        ecs_cluster_logical_id = "Ecs-Cluster"

        vpc = ec2.Vpc.from_lookup(self, "Vpc", vpc_id=constants.ECS_CLUSTER_VPC_ID)

        security_group = ec2.SecurityGroup.from_security_group_id(
            self,
            "Security-Group",
            security_group_id=constants.ECS_CLUSTER_SECURITY_GROUP_ID,
        )

        ecs_cluster = ecs.Cluster.from_cluster_attributes(
            self,
            ecs_cluster_logical_id,
            vpc=vpc,
            security_groups=[security_group],
            cluster_arn=constants.ECS_CLUSTER_ARN,
            cluster_name=constants.ECS_CLUSTER_NAME,
        )

        return ecs_cluster
