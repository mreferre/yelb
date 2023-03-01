#!/usr/bin/env node
import { Construct } from 'constructs';
import { App, Stack } from 'aws-cdk-lib';                 // core constructs

import { YelbEcsStack } from '../lib/yelb-ecs-stack';

const app = new App();
new YelbEcsStack(app, 'YelbEcsStack');
