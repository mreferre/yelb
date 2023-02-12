import pathlib

from aws_cdk import aws_codebuild as codebuild
from aws_cdk import aws_codecommit as codecommit
from aws_cdk import aws_iam as iam
from aws_cdk import aws_lambda as lambda_
from aws_cdk import triggers
from constructs import Construct

BUILD_SPEC = {
    "phases": {
        "install": {
            "runtime-versions": {"python": "3.9"},
            "commands": [
                "npm ci",
                "pip install -r requirements.txt",
            ],
        },
        "pre_build": {
            "commands": [
                "npx cdk synth",
            ]
        },
        "build": {
            "commands": [
                "npx cdk deploy --all --require-approval never",
            ]
        },
    }
}


class Bootstrap(Construct):
    def __init__(
        self,
        scope: Construct,
        id: str,
        component_name: str,
        repository: codecommit.Repository,
        **kwargs,
    ) -> None:
        super().__init__(scope, id, **kwargs)

        build_project = codebuild.Project(
            self,
            f"{component_name}-Bootstrap-Project",
            source=codebuild.Source.code_commit(repository=repository),
            build_spec=codebuild.BuildSpec.from_object_to_yaml(value=BUILD_SPEC),
        )

        runtime_path = str(pathlib.Path(__file__).parent.joinpath("runtime").resolve())

        bootstrap_function = triggers.TriggerFunction(
            self,
            f"{component_name}-Bootstrap-Function",
            code=lambda_.Code.from_asset(runtime_path),
            handler="bootstrap_lambda.lambda_handler",
            runtime=lambda_.Runtime.PYTHON_3_9,
            execute_after=[build_project],
            environment={"PROJECT_NAME": build_project.project_name},
        )

        bootstrap_function.add_to_role_policy(
            statement=iam.PolicyStatement(
                resources=[
                    build_project.project_arn,
                ],
                actions=[
                    "codebuild:StartBuild",
                ],
                effect=iam.Effect.ALLOW,
            )
        )
