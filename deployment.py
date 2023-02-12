import os
import shutil
from pathlib import Path
from typing import Any

from aws_cdk import CfnOutput
from aws_cdk import Fn
from aws_cdk import Stack
from aws_cdk import aws_codecommit as codecommit
from aws_cdk import aws_ec2 as ec2
from aws_cdk import aws_s3_assets as s3_assets
from aws_cdk import aws_servicediscovery as servicediscovery
from constructs import Construct

import constants


class OneBoxFleetLabInfrastructure(Stack):
    def __init__(self, scope: Construct, id_: str, **kwargs: Any) -> None:
        super().__init__(scope, id_, **kwargs)

        self.namespace = self.__create_service_discovery_namespace()
        components_constant_values = self.__get_static_constants_values(self.namespace)

        components_code_directories = self.__create_code_directories_from_templates(
            components_constant_values
        )

        self.codecommit_repositories = (
            self.__create_codecommit_repositories_for_yelb_components(
                components_code_directories
            )
        )

        CfnOutput(
            self,
            "Yelb-Namespace-ARN",
            value=self.namespace.namespace_arn,
            export_name=constants.YELB_NAMESPACE_ARN_EXPORT_NAME,
        )

        CfnOutput(
            self,
            "Yelb-Namespace-ID",
            value=self.namespace.namespace_id,
            export_name=constants.YELB_NAMESPACE_ID_EXPORT_NAME,
        )

        for component_name, repository in self.codecommit_repositories.items():
            CfnOutput(
                self,
                f"{component_name}-Repository-URL",
                value=repository.repository_clone_url_http,
            )

    def __get_static_constants_values(
        self, namespace: servicediscovery.PrivateDnsNamespace
    ) -> dict[str, str]:
        constant_values = {}

        constant_values[
            "YELB_NAMESPACE_ARN_EXPORT_NAME"
        ] = constants.YELB_NAMESPACE_ARN_EXPORT_NAME
        constant_values[
            "YELB_NAMESPACE_ID_EXPORT_NAME"
        ] = constants.YELB_NAMESPACE_ID_EXPORT_NAME
        constant_values["YELB_NAMESPACE_NAME"] = namespace.namespace_name

        constant_values[
            "ECS_CLUSTER_VPC_ID_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_VPC_ID_EXPORT_NAME
        constant_values[
            "ECS_CLUSTER_SECURITY_GROUP_ID_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_SECURITY_GROUP_ID_EXPORT_NAME
        constant_values[
            "ECS_CLUSTER_NAME_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_NAME_EXPORT_NAME
        constant_values[
            "ALB_PUBLIC_LISTENER_ARN_EXPORT_NAME"
        ] = constants.ALB_PUBLIC_LISTENER_ARN_EXPORT_NAME

        constant_values[
            "ALB_YELP_APPLICATION_PATH"
        ] = constants.ALB_YELP_APPLICATION_PATH

        constant_values[
            "ECS_CLUSTER_PUBLIC_SUBNET_ONE_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_PUBLIC_SUBNET_ONE_EXPORT_NAME
        constant_values[
            "ECS_CLUSTER_PUBLIC_SUBNET_TWO_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_PUBLIC_SUBNET_TWO_EXPORT_NAME
        constant_values[
            "ECS_CLUSTER_PRIVATE_SUBNET_ONE_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_PRIVATE_SUBNET_ONE_EXPORT_NAME
        constant_values[
            "ECS_CLUSTER_PRIVATE_SUBNET_TWO_EXPORT_NAME"
        ] = constants.ECS_CLUSTER_PRIVATE_SUBNET_TWO_EXPORT_NAME

        return constant_values

    def __create_service_discovery_namespace(
        self,
    ) -> servicediscovery.PrivateDnsNamespace:
        vpc = self.__get_vpc_from_cloudformation_exports()

        return servicediscovery.PrivateDnsNamespace(
            self,
            "Yelb-Namespace",
            vpc=vpc,
            name=constants.YELB_NAMESPACE_NAME,
        )

    def __get_vpc_from_cloudformation_exports(self) -> ec2.Vpc:
        vpc_id = Fn.import_value(constants.ECS_CLUSTER_VPC_ID_EXPORT_NAME)
        availability_zones = Fn.get_azs(self.region)[0:2]
        return ec2.Vpc.from_vpc_attributes(
            self, "Vpc", availability_zones=availability_zones, vpc_id=vpc_id
        )

    def __create_code_directories_from_templates(
        self,
        constant_values: dict[str, str],
        source_templates_path: str = constants.YELB_CODE_TEMPLATES_DIRECTORY_PATH,
        skeleton_directory_name=constants.TEMPLATE_SKELETON_DIRECTORY_NAME,
        runtimes_directory_name=constants.TEMPLATE_RUNTIMES_DIRECTORY_NAME,
        constants_file_name=constants.TEMPLATE_CONSTANTS_FILE_NAME,
        destination_path: str = constants.YELB_COMPONENTS_CODE_DIRECTORY_PATH,
    ) -> dict[str, str]:
        """
        Creates a directory with a CDK application for each of the yelb components.
        The CDK application contains both infrastructure and runtime code.
        The function deletes the `destination_path` if exists and re-creates it.

        `constant_values` holds the required parameters gotten from the output the ECS Cluster CloudFormation stack.
        `constant_values` is a dictionaty that looks like: `{"CONSTANT_PLACEHOLDER_NAME": value, ...}`.
        """

        components_code_directories = {}

        # Delete and re-create the destination directory
        if Path(destination_path).exists():
            shutil.rmtree(f"{destination_path}/")
        os.mkdir(destination_path)

        template_skeleton_directory_path = (
            f"{source_templates_path}/{skeleton_directory_name}/"
        )
        template_runtimes_directory_path = (
            f"{source_templates_path}/{runtimes_directory_name}/"
        )
        template_constant_file_path = f"{source_templates_path}/{constants_file_name}"

        with open(template_constant_file_path, "r") as template_constant_file:
            template_constant_content_with_placeholders = template_constant_file.read()

        all_yelb_components: dict[str, dict[str, str]] = {}
        all_yelb_components.update(constants.YELB_PUBLIC_COMPONENSTS)
        all_yelb_components.update(constants.YELB_PRIVATE_COMPONENSTS)

        for (
            yelb_component_name,
            yelb_component_parameters,
        ) in all_yelb_components.items():
            component_code_directory_path = (
                f"{destination_path}/{yelb_component_name.lower()}/"
            )
            components_code_directories[
                yelb_component_name
            ] = component_code_directory_path

            # Copy skeleton (common) files
            shutil.copytree(
                src=f"{template_skeleton_directory_path}/",
                dst=f"{component_code_directory_path}/",
            )

            # Replace constant placeholders with the respective values from `constant_values` and `yelb_component_parameters`
            component_constant_values = constant_values
            component_constant_values["COMPONENT_NAME"] = yelb_component_name
            component_constant_values["COMTAINER_PORT"] = yelb_component_parameters.get(
                "COMTAINER_PORT", ""
            )
            component_constant_values[
                "SERVICE_DESIRED_COUNT"
            ] = yelb_component_parameters.get("SERVICE_DESIRED_COUNT", "")
            component_constant_values[
                "HEALTH_CHECK_PATH"
            ] = yelb_component_parameters.get("HEALTH_CHECK_PATH", "")
            component_constant_values[
                "HEALTH_CHECK_PORT"
            ] = yelb_component_parameters.get(
                "HEALTH_CHECK_PORT", component_constant_values["COMTAINER_PORT"]
            )
            component_constant_values["SHOULD_ATTACH_TO_PUBLIC_ALB"] = (
                yelb_component_name in constants.YELB_PUBLIC_COMPONENSTS.keys()
            )

            constans_file_content = template_constant_content_with_placeholders.format(
                **component_constant_values
            )

            # Write the filled in constants to file
            component_constants_file_path = (
                f"{component_code_directory_path}/{constants_file_name}"
            )
            with open(component_constants_file_path, "w") as constants_file:
                constants_file.write(constans_file_content)

            # Copy runtime code
            component_runtime_directory_path = f"{template_runtimes_directory_path}/{yelb_component_name.lower()}-runtime/"
            shutil.copytree(
                src=f"{component_runtime_directory_path}",
                dst=f"{component_code_directory_path}/runtime",
            )
        return components_code_directories

    def __create_codecommit_repositories_for_yelb_components(
        self, components_code_directories: dict[str, str]
    ) -> dict[str, codecommit.Repository]:
        codecommit_repositories = {}

        for component_name, code_directory in components_code_directories.items():
            code = s3_assets.Asset(self, f"{component_name}-Code", path=code_directory)

            codecommit_repository = codecommit.Repository(
                self,
                f"{component_name}-Repository",
                repository_name=component_name.lower(),
            )
            codecommit_repositories[component_name] = codecommit_repository

        return codecommit_repositories
