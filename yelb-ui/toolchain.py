import json
import pathlib
from typing import Any

from deployment import YelbUiInfrastructure

import aws_cdk.aws_codebuild as codebuild
from aws_cdk import aws_codepipeline as codepipeline
from aws_cdk import aws_codepipeline_actions as codepipeline_actions
from aws_cdk import Stack
from aws_cdk import Stage
from aws_cdk import Environment
from aws_cdk import aws_ecr as ecr
from constructs import Construct

COMPONENT_NAME = "Yelb-Ui"

ECR_REPOSITORY_NAME = COMPONENT_NAME.lower

BUILD_STAGE_NAME = f"{COMPONENT_NAME}-Build"
BUILD_STAGE_DESCRIPTION = (
    f"Builds the {COMPONENT_NAME} component using the buildspec.yaml file"
)
BUILD_STAGE_BUILDSPEC_PATH = "./specfiles/buildspec.yaml"

ONEBOX_STAGE_NAME = f"{COMPONENT_NAME}-OneBox"
FLEET_STAGE_NAME = f"{COMPONENT_NAME}-Fleet"


class YelbUiPipeline(Stage):
    def __init__(
        self,
        scope: Construct,
        id_: str,
        infrastructure: YelbUiInfrastructure,
        **kwargs: Any,
    ):
        super().__init__(scope, id_, **kwargs)

        pipeline = codepipeline.Pipeline(self, f"{COMPONENT_NAME}-Pipeline")

        source_output = codepipeline.Artifact("SourceArtifact")
        pipeline.add_stage(
            stage_name="Source",
            actions=[
                codepipeline_actions.EcrSourceAction(
                    action_name="CodeCommitSource",
                    repository=infrastructure.ecr_repository,
                    output=source_output,
                ),
            ],
        )

        codebuild.Project(
            self,
            "yelb-ui-codebuild-project",
            project_name="yelb-ui",
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage,
            ),
            build_spec=codebuild.BuildSpec.from_source_filename(
                BUILD_STAGE_BUILDSPEC_PATH
            ),
        )

        pipeline.add_stage(
            stage_name=BUILD_STAGE_NAME,
            actions=[
                codepipeline_actions.CodeBuildAction(
                    action_name=BUILD_STAGE_NAME,
                    input=source_output,
                ),
            ],
        )

    # @staticmethod
    # def __add_onebox_stage(pipeline: pipelines.CodePipeline) -> None:
    #     production = Stage(
    #         pipeline,
    #         ONEBOX_STAGE_NAME,
    #     )

    #     backend = Backend(
    #         production,
    #         constants.APP_NAME + ONEBOX_STAGE_NAME,
    #         stack_name=constants.APP_NAME + ONEBOX_STAGE_NAME,
    #         api_lambda_reserved_concurrency=10,
    #         database_dynamodb_billing_mode=dynamodb.BillingMode.PROVISIONED,
    #     )
    #     api_endpoint_env_var_name = constants.APP_NAME.upper() + "_API_ENDPOINT"
    #     smoke_test_commands = [f"curl ${api_endpoint_env_var_name}"]
    #     smoke_test = pipelines.ShellStep(
    #         "SmokeTest",
    #         env_from_cfn_outputs={api_endpoint_env_var_name: backend.api_endpoint},
    #         commands=smoke_test_commands,
    #     )
    #     pipeline.add_stage(production, post=[smoke_test])
