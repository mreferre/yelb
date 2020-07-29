import * as cdk from '@aws-cdk/core';
import * as ecs from '@aws-cdk/aws-ecs';
import * as ec2 from '@aws-cdk/aws-ec2';
import * as ecs_patterns from '@aws-cdk/aws-ecs-patterns';
import * as servicediscovery from '@aws-cdk/aws-servicediscovery';

export class YelbEcsStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const yelbvpc = new ec2.Vpc(this, "yelb-vpc", {});

    const yelbcluster = new ecs.Cluster(this, "yelb-cluster", {
      clusterName: "yelb-cluster",
      vpc: yelbvpc,
      });

    const yelbnamespace = new servicediscovery.PrivateDnsNamespace(this, 'Namespace', {
      name: 'yelb.local',
      vpc: yelbvpc,
    }); 

    // ------------------------------------------------------------------------------------------------- //
    const yelbuitaskdef = new ecs.FargateTaskDefinition(this, "yelb-ui-taskdef", {
      memoryLimitMiB: 2048, // Default is 512
      cpu: 512, // Default is 256
    });

    const yelbuicontainer = yelbuitaskdef.addContainer("yelb-ui-container", {
      image: ecs.ContainerImage.fromRegistry("mreferre/yelb-ui:0.7"), 
      environment: {"SEARCH_DOMAIN": yelbnamespace.namespaceName}
    })

    yelbuicontainer.addPortMappings({
      containerPort: 80
    });

    // Create a load-balanced Fargate service and make it public
    const yelbuiservice = new ecs_patterns.ApplicationLoadBalancedFargateService(this, "yelb-ui-service", {
      cluster: yelbcluster, // Required
      desiredCount: 3, // Default is 1
      publicLoadBalancer: true, // Default is false
      serviceName: "yelb-ui",
      taskDefinition: yelbuitaskdef,
      cloudMapOptions: { name: "yelb-ui", cloudMapNamespace: yelbnamespace}
    });

    // ------------------------------------------------------------------------------------------------- //


    // ------------------------------------------------------------------------------------------------- //

    const yelbappservertaskdef = new ecs.FargateTaskDefinition(this, "yelb-appserver-taskdef", {
      memoryLimitMiB: 2048, // Default is 512
      cpu: 512, // Default is 256
    });

    const yelbappservercontainer = yelbappservertaskdef.addContainer("yelb-appserver-container", {
      image: ecs.ContainerImage.fromRegistry("mreferre/yelb-appserver:0.5"), 
      environment: {"SEARCH_DOMAIN": yelbnamespace.namespaceName}
    })

    // Create a standard Fargate service 
    const yelbappserverservice = new ecs.FargateService(this, "yelb-appserver-service", {
      cluster: yelbcluster, // Required
      desiredCount: 2, // Default is 1
      serviceName: "yelb-appserver",
      taskDefinition: yelbappservertaskdef,
      cloudMapOptions: { name: "yelb-appserver", cloudMapNamespace: yelbnamespace}
    });    

    yelbappserverservice.connections.allowFrom(yelbuiservice.service, ec2.Port.tcp(4567))

    // ------------------------------------------------------------------------------------------------- //


    // ------------------------------------------------------------------------------------------------- //

    const yelbdbtaskdef = new ecs.FargateTaskDefinition(this, "yelb-db-taskdef", {
      memoryLimitMiB: 2048, // Default is 512
      cpu: 512, // Default is 256
    });

    const yelbdbcontainer = yelbdbtaskdef.addContainer("yelb-db-container", {
      image: ecs.ContainerImage.fromRegistry("mreferre/yelb-db:0.5"), 
    })

    // Create a standard Fargate service 
    const yelbdbservice = new ecs.FargateService(this, "yelb-db-service", {
      cluster: yelbcluster, // Required
      serviceName: "yelb-db",
      taskDefinition: yelbdbtaskdef,
      cloudMapOptions: { name: "yelb-db", cloudMapNamespace: yelbnamespace}
    });    

    yelbdbservice.connections.allowFrom(yelbappserverservice, ec2.Port.tcp(5432))


    // ------------------------------------------------------------------------------------------------- //


    // ------------------------------------------------------------------------------------------------- //

    const redisservertaskdef = new ecs.FargateTaskDefinition(this, "redis-server-taskdef", {
      memoryLimitMiB: 2048, // Default is 512
      cpu: 512, // Default is 256
    });

    const redisservercontainer = redisservertaskdef.addContainer("redis-server", {
      image: ecs.ContainerImage.fromRegistry("redis:4.0.2"), 
    })

    // Create a standard Fargate service 
    const redisserverservice = new ecs.FargateService(this, "redis-server-service", {
      cluster: yelbcluster, // Required
      serviceName: "redis-server",
      taskDefinition: redisservertaskdef,
      cloudMapOptions: { name: "redis-server", cloudMapNamespace: yelbnamespace}
    });    

    redisserverservice.connections.allowFrom(yelbappserverservice, ec2.Port.tcp(6379))

    // ------------------------------------------------------------------------------------------------- //

  }
}
