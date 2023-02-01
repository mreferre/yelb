from aws_cdk import Duration
from aws_cdk import aws_ec2 as ec2
from aws_cdk import aws_ecr as ecr
from aws_cdk import aws_elasticloadbalancingv2 as elbv2
from aws_cdk import aws_ecs as ecs
from aws_cdk import aws_servicediscovery as servicediscovery
from constructs import Construct

import constants


class EcsService(Construct):
    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        ecr_repository: ecr.Repository,
        ecs_cluster: ecs.Cluster,
        yelb_namespace: servicediscovery.PrivateDnsNamespace,
        **kwargs,
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.task_definition = self.__create_task_definition()
        self.__add_container_to_task_definition(
            ecr_repository, yelb_namespace, self.task_definition
        )

        self.service = self.__create_service(
            ecs_cluster=ecs_cluster,
            service_name=constants.SERVICE_NAME,
            task_definition=self.task_definition,
            desired_count=constants.SERVICE_DESIRED_COUNT,
            namespace=yelb_namespace,
        )

        self.__attach_service_to_alb_listener(self.service)

        self.__setup_security_groups_for_service(self.service)

    def __create_task_definition(self) -> ecs.Ec2TaskDefinition:
        task_definition = ecs.Ec2TaskDefinition(
            self,
            f"{constants.COMPONENT_NAME}-Task-Definition",
            network_mode=ecs.NetworkMode.AWS_VPC,
        )

        return task_definition

    def __add_container_to_task_definition(
        self,
        ecr_repository: ecr.Repository,
        yelb_namespace: servicediscovery.PrivateDnsNamespace,
        task_definition: ecs.TaskDefinition,
    ) -> ecs.ContainerDefinition:

        container = task_definition.add_container(
            f"{constants.COMPONENT_NAME}-Container",
            image=ecs.ContainerImage.from_ecr_repository(ecr_repository),
            memory_limit_mib=constants.CONTAINER_MEMORY,
            cpu=constants.CONTAINER_CPU,
            environment={
                constants.CONTAINER_ENVIRONMENT_SEARCH_DOMAIN_KEY: yelb_namespace.namespace_name
            },
            logging=ecs.LogDriver.aws_logs(stream_prefix=constants.COMPONENT_NAME)
        )

        container.add_port_mappings(
            ecs.PortMapping(
                container_port=constants.COMTAINER_PORT,
            )
        )

        return container

    def __create_service(
        self,
        ecs_cluster: ecs.Cluster,
        service_name: str,
        task_definition: ecs.TaskDefinition,
        desired_count: int,
        namespace: servicediscovery.PrivateDnsNamespace,
    ) -> ecs.Ec2Service:

        cloud_map_options = ecs.CloudMapOptions(
            cloud_map_namespace=namespace,
            name=constants.SERVICE_NAME,
            dns_record_type=servicediscovery.DnsRecordType.A,
        )

        ecs_service = ecs.Ec2Service(
            self,
            f"{constants.COMPONENT_NAME}-Service",
            cluster=ecs_cluster,
            service_name=service_name,
            task_definition=task_definition,
            desired_count=desired_count,
            cloud_map_options=cloud_map_options,
        )

        return ecs_service

    def __attach_service_to_alb_listener(self, service: ecs.Ec2Service) -> None:

        vpc = ec2.Vpc.from_lookup(self, "Vpc", vpc_id=constants.ECS_CLUSTER_VPC_ID)
              
        alb_listener = elbv2.ApplicationListener.from_lookup(
            self,
            "Alb-Listener",
            listener_arn=constants.ALB_PUBLIC_LISTENER_ARN,
        )

        health_check = elbv2.HealthCheck(
            protocol=elbv2.Protocol.HTTP,
            path=constants.HEALTH_CHECK_PATH,
            interval=Duration.seconds(6),
            timeout=Duration.seconds(5),
            healthy_threshold_count=2
        )

        target_group = elbv2.ApplicationTargetGroup(
            self,
            f"{constants.COMPONENT_NAME}-Target-Group",
            port=constants.COMTAINER_PORT,
            protocol=elbv2.ApplicationProtocol.HTTP,
            targets=[service],
            health_check=health_check,
            target_type=elbv2.TargetType.IP,
            vpc=vpc,
        )

        listener_rule = elbv2.ApplicationListenerRule(
            self,
            f"{constants.COMPONENT_NAME}-Listener-Rule",
            listener=alb_listener,
            priority=10,
            conditions=[elbv2.ListenerCondition.path_patterns([constants.ALB_YELP_APPLICATION_PATH])],
            action=elbv2.ListenerAction.forward(target_groups=[target_group])
        )

    def __setup_security_groups_for_service(self, service: ecs.Ec2Service) -> None:
        service.connections.allow_from_any_ipv4(
            port_range=ec2.Port.tcp(constants.COMTAINER_PORT),
            description=f"Allow inbound traffic to {constants.COMPONENT_NAME}",
        )
