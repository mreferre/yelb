#!/usr/bin/env python3
import os

import aws_cdk as cdk

import constants
from deployment import YelbRedisInfrastructure

app = cdk.App()
yelb_component = YelbRedisInfrastructure(
    app,
    f"{constants.COMPONENT_NAME}-Infrastructure",
    env=cdk.Environment(
        account=os.environ["CDK_DEFAULT_ACCOUNT"],
        region=os.environ["CDK_DEFAULT_REGION"],
    ),
)

app.synth()
