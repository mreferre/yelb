#!/usr/bin/env python3
import os

import aws_cdk as cdk

from deployment import OneBoxFleetLabInfrastructure

app = cdk.App()

onebox_fleet = OneBoxFleetLabInfrastructure(
    app,
    "OneBox-Fleet",
    env=cdk.Environment(
        account=os.environ["CDK_DEFAULT_ACCOUNT"],
        region=os.environ["CDK_DEFAULT_REGION"],
    ),
)

app.synth()
