#!/usr/bin/env python3
import os

from aws_cdk import App
from aws_cdk import Environment

import constants
from deployment import YelbComponent

app = App()

yelb_component = YelbComponent(
    app,
    f"{constants.COMPONENT_NAME}-Infrastructure",
    should_attach_to_public_alb=constants.SHOULD_ATTACH_TO_PUBLIC_ALB,
    env=Environment(
        account=os.environ["CDK_DEFAULT_ACCOUNT"],
        region=os.environ["CDK_DEFAULT_REGION"],
    ),
)

app.synth()
