import json
import os

import boto3

client = boto3.client("codebuild")

PROJECT_NAME = os.getenv("PROJECT_NAME")


def lambda_handler(event, context):
    response = client.start_build(
        projectName=PROJECT_NAME,
    )

    return json.dumps({"statusCode": 200, "body": response["buildStatus"]})
