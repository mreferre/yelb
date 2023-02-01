#!/usr/bin/env python3
import os

import aws_cdk as cdk

from deployment import YelbUiInfrastructure

import constants

app = cdk.App()
yelb_component = YelbUiInfrastructure(
    app,
    f"{constants.COMPONENT_NAME}-Infrastructure",
    env=cdk.Environment(
        account=os.environ["CDK_DEFAULT_ACCOUNT"],
        region=os.environ["CDK_DEFAULT_REGION"],
    ),
)

app.synth()
