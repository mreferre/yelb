#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { YelbEcsStack } from '../lib/yelb-ecs-stack';

const app = new cdk.App();
new YelbEcsStack(app, 'YelbEcsStack');
