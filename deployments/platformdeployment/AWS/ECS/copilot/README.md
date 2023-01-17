This is a sample which uses [AWS Copilot](https://aws.amazon.com/containers/copilot/) for deploying
the Yelb application. Each component of Yelb is represented as a separate service in the Copilot
config (svcname/manifest.yml). 

This folder contains the pre-created manifests. When Copilot detects that a service you are trying to create on the CLI already has a corresponding manifest (which matches the name of the service) it will skip the creation of the manifest. This means if you want to fine tune these services, you should tweak the manifests and not the commands below. 

> For example, the environment manifest in the `envioronments/yelb-env` folder has been tweaked from the default to enable Container Insights. More importantly, the `yelb-appserver` and `yelb-ui` manifests have a variable that needs to be injected for service discovery to work properly (more info [here on how Copilot service discovery](https://aws.github.io/copilot-cli/docs/developing/service-discovery/) works and [here on the application service discovery requirements](https://github.com/mreferre/yelb/blob/master/yelb-appserver/startup.sh#L3-L7))

These commands assume you have the Copilot tool installed and you have an AWS CLI profile called `default` already created. Make sure you are running these commands from the `/deployments/platformdeployment/AWS/ECS/copilot` directory.

First initialize the app with this command (the app name - `yelb` - is specified in the `.workspace` file distributed with this repo so copilot won't ask for it):
```
copilot app init
```
Then initialize an environment to deploy the Yelb application:
```
copilot env init --name yelb-env --default-config --profile default 
```
> Note that while the manifest file exists, this won't stop copilot to ask configuration questions (to be then ignored because the file rules). We avoid being asked questions by adding the `--default-config` flag.

At this point we are ready to register the 4 services that comprise the application. Similarly to what we have done for the environment, we are initializing them with the commands below and copilot will detect the existing manifest files:  
```
copilot svc init --app yelb --name redis-server --image redis:4.0.2 --svc-type "Backend Service" 
copilot svc init --app yelb --name yelb-db --dockerfile ../../../../../yelb-db/Dockerfile --svc-type "Backend Service"
copilot svc init --app yelb --name yelb-appserver --dockerfile ../../../../../yelb-appserver/Dockerfile --svc-type "Backend Service"
copilot svc init --app yelb --name yelb-ui --dockerfile ../../../../../yelb-ui/Dockerfile --svc-type "Load Balanced Web Service" --port 80
```
> Copilot supports both pointing to a `Dockerfile` or to an existing container image. Here we opted for the former, if you want to speed up the deployment you can change this to point to the existing images (check the other IaC files in this repo for the latest images available). Also note that the source of truth in this workflow is the manifest file for each of the services (the command line above has been filled for educational purposes only but the flags will be ignored because the manifests exist already).   

Neither the environment nor the service exist at this point. They have only been initialized (that is, copilot is aware of their definition). We are now going to actually deploy these objects:

```
copilot env deploy --name yelb-env

copilot svc deploy --name yelb-db --env yelb-env
copilot svc deploy --name redis-server --env yelb-env
copilot svc deploy --name yelb-appserver --env yelb-env
copilot svc deploy --name yelb-ui --env yelb-env
```
The application should be deployed at this point. 

The `yelb-ui` service is exposed as a `Load Balanced Web Service` type and you can find out the endpoint by "showing" the service itself:

```
copilot svc show --name yelb-ui
About

  Application  yelb
  Name         yelb-ui
  Type         Load Balanced Web Service

Configurations

  Environment  Tasks     CPU (vCPU)  Memory (MiB)  Platform      Port
  -----------  -----     ----------  ------------  --------      ----
  yelb-env     1         0.25        512           LINUX/X86_64  80

Routes

  Environment  URL
  -----------  ---
  yelb-env     http://yelb-Publi-1OZVASLLPNISZ-1354305969.us-west-2.elb.amazonaws.com

Service Discovery

  Environment  Namespace
  -----------  ---------
  yelb-env     yelb-ui.yelb-env.yelb.local:80

Variables

  Name                                Container  Environment  Value
  ----                                ---------  -----------  -----
  COPILOT_APPLICATION_NAME            yelb-ui    yelb-env     yelb
  COPILOT_ENVIRONMENT_NAME              "          "          yelb-env
  COPILOT_LB_DNS                        "          "          yelb-Publi-1OZVASLLPNISZ-1354305969.us-west-2.elb.amazonaws.com
  COPILOT_SERVICE_DISCOVERY_ENDPOINT    "          "          yelb-env.yelb.local
  COPILOT_SERVICE_NAME                  "          "          yelb-ui
  SEARCH_DOMAIN                         "          "          yelb-env.yelb.local

```

Pointing the web browser to the LB endpoint should render the Yelb home page. 
