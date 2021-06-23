This is a sample which uses [AWS Copilot](https://aws.amazon.com/containers/copilot/) for deploying
the Yelb application. Each component of Yelb is represented as a separate service in the Copilot
config (svcname/manifest.yml). 

This folder contains the pre-created manifests. When Copilot detects that a service you are trying to create on the CLI already has a corresponding manifest (which matches the name of the service) it will skip the creation of the manifest. This means if you want to fine tune these services, you should tweak the manifests and not the commands below. 

These commands assume you have the Copilot tool installed and you have an AWS CLI profile called `default` already created. Make sure you are running these commands from the `/deployments/platformdeployment/AWS/ECS` folder because the copilot binary will look for a `copilot` folder.

First initialize the app with this command:
```
$ copilot app init
```
Then initialize an environment to deploy the Yelb application:
```
$ copilot env init --name yelb-env --default-config —-profile default 
```
At this point we are ready to deploy the 4 services that comprise the applicatio:
```
$ copilot init --app yelb --name redis-server --image redis:redis:4.0.2 --type "Backend Service" --deploy 
$ copilot init --app yelb --name yelb-db --dockerfile ../../../../yelb-db/Dockerfile --type "Backend Service" --deploy 
$ copilot init --app yelb --name yelb-appserver --dockerfile ../../../../yelb-appserver/Dockerfile --type "Backend Service" --deploy 
$ copilot init --app yelb --name yelb-ui --dockerfile ../../../../yelb-ui/Dockerfile --type "Load Balanced Web Service" --port 80 --deploy
```

Once all commands have completed you should see all services:
```
$ copilot svc ls 
Name                Type
----                ----
redis-server        Backend Service
yelb-appserver      Backend Service
yelb-db             Backend Service
yelb-ui             Load Balanced Web Service
```

The `yelb-ui` service is exposed as a `Load Balanced Web Service` type and you can find out the endpoint by "showing" the service itself:

```
$ copilot svc show --name yelb-ui
About

  Application       yelb
  Name              yelb-ui
  Type              Load Balanced Web Service

Configurations

  Environment       Tasks               CPU (vCPU)          Memory (MiB)        Port
  -----------       -----               ----------          ------------        ----
  test              1                   0.25                512                 80

Routes

  Environment       URL
  -----------       ---
  test              http://yelb-Publi-1VTBONVYKH6CW-1859885541.us-west-2.elb.amazonaws.com

Service Discovery

  Environment       Namespace
  -----------       ---------
  test              yelb-ui.yelb.local:80

Variables

  Name                                Container           Environment         Value
  ----                                ---------           -----------         -----
  COPILOT_APPLICATION_NAME            yelb-ui             test                yelb
  COPILOT_ENVIRONMENT_NAME              "                   "                 test
  COPILOT_LB_DNS                        "                   "                 yelb-Publi-1VTBONVYKH6CW-1859885541.us-west-2.elb.amazonaws.com
  COPILOT_SERVICE_DISCOVERY_ENDPOINT    "                   "                 yelb.local
  COPILOT_SERVICE_NAME                  "                   "                 yelb-ui
  SEARCH_DOMAIN                         "                   "                 yelb.local
$ 
```

Pointing the web browser to the LB endpoint should render the Yelb home page. 
