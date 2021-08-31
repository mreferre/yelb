#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { YelbEcsStack } from '../lib/yelb-ecs-stack';

const app = new cdk.App();
const stackName = 'Yelb-' + process.env.STAGE;
new YelbEcsStack(app, stackName, {
    env: {
        account: process.env.CDK_DEFAULT_ACCOUNT, 
        region: process.env.CDK_DEFAULT_REGION 
    }
});
