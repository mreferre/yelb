### Terraform configs

- Creates own VPC
- One service
- One task of all containers
- Only public ip is ALB
- Communicates via awsvpc networking using localhost only (fast and secure)
- No nameserver needed
- CloudWatch logs

NOTE: Check container id's and versions first!
I have fetched container from docker registry and made local changes to it.

I have made changes to ui and appserver containers to accept host defitions from environment:
`APPSERVER_HOST`, `DB_HOST` and `CACHE_HOST`. These are then supplied to each task.
AWSVPC networking allows the containers inside same task to talk each other via localhost, so
we can set localhost to them using ENV variables. If those variables are not set it uses default names like yelb-appserver etc

### AWS region

AWS region is taken from AWS profile, make sure you have set it in .aws/config file:
example:

```
[default]
region = eu-central-1
```

### Terraform init

Use `terraform init` once, it will create terraform working environment here.
To apply changes to AWS use `terraform apply`. It will print changes it is going to make to cloud and prompts your confirmation.
It will create ECS repo for us but fails with task creation since we don't yet have containers.
Thats ok, you can now push containers (see below) to it and after that rerun `terraform apply` and
it will create rest of AWS ECS environment.
When its done it outputs our loadbalancer URL which we can use to start application in browser.

### Pull commands to fetch containers locally

Check those paths and versions

```
docker pull docker.io/mreferre/yelb-db:0.6
docker pull docker.io/mreferre/yelb-appserver:0.6
docker pull docker.io/mreferre/yelb-ui:0.6
docker pull redis:4.0.2
```

### Login to ecr via powershell

Add cmd /c if using Powershell. Othewise just use quoted part.

```
cmd /c "aws ecr get-login-password --region <your region here> | docker login --username AWS --password-stdin <your ecr registry here>"
```

### Build and push

For changed containers if you made any changes to a container

#### Changed yelb modules

If you haven't done any changes to any modules you can skip this.

Change to module folder where Dockerfile is. Ex. yelb-appserver

```
docker build -t <module name here> .
docker tag yelb-appserver <your ecr repository here>/<module name here>:latest
docker push <your ecr repository here>/<module name here>:latest
```

#### Tag rest unchanged containers so we can push them to correct ecr repo

If there aren't any changed container do this for all containers you pulled

Examples

```
docker tag docker.io/mreferre/yelb-db:0.6 <your ecr registry here>/yelb-db:latest
docker tag redis:4.0.2 <your ecr registry here>/redis-server:latest
```

#### Push rest unchanged containers

If there aren't any changed container do this for all containers you pulled

Examples

```
docker push <your ecr registry here>/yelb-db:latest
docker push <your ecr registry here>/redis-server:latest
```

#### Updating(pushing) new version

You can force ECS to update service from ECS

```
aws ecs update-service --cluster yelb-cluster --service yelb-ui-service --force-new-deployment
```
