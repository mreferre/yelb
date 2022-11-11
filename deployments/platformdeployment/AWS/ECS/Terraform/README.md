### Terraform configs

- Creates own VPC
- One service
- One task with all containers
- Only public endpoint is the ALB
- Communicates via awsvpc networking using localhost only (fast and secure)
- No nameserver needed
- CloudWatch logs

NOTE: Check container id's and versions first!
I have fetched container from docker registry and made local changes to it.

Using "RACK_ENV=custom" we can define hosts from servers.
AWSVPC networking allows the containers inside same task to talk each other via localhost, so
we can set localhost to them using ENV variables.
This is already done in templates/yelb_app.json.tpl.

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
It will create ECS repo for us but it can fail with task creation since we don't yet have containers.
It thats the case its ok, you can push containers (see below) to it and after that rerun `terraform apply` and
it will create rest of AWS ECS Fargate environment.
When its done it outputs our loadbalancer URL which we can use to start application in browser.

### Pull containers

Pull "static containers". Check latest version used. You can also pull appserver and ui if you have not changed them.

```
docker pull docker.io/mreferre/yelb-db:0.6
docker pull redis:4.0.2
```

### Login to ecr via powershell

Add cmd /c if using Powershell. Othewise just use quoted part.

```
cmd /c "aws ecr get-login-password --region <your region here> | docker login --username AWS --password-stdin <your ecr registry here>"
```

#### Changed yelb modules

If you haven't done any changes to any modules you can skip this.
Check you repository uri from AWS Console ECR repository page.
There is a button "View push commands".

Change to module folder where Dockerfile is. Ex. yelb-appserver

```
docker build -t <module name here> .
docker tag yelb-appserver <your ecr repository here>/<module name here>:latest
docker push <your ecr repository here>/<module name here>:latest
```

#### Tag and push containers

If there aren't any changed containers do this for all containers you pulled.
You need to push 4 containers appserver,ui,redis and db.

Examples

```
docker tag docker.io/mreferre/yelb-db:0.6 <your ecr registry here>/yelb-db:latest
docker tag redis:4.0.2 <your ecr registry here>/redis-server:latest
docker push <your ecr registry here>/yelb-db:latest
docker push <your ecr registry here>/redis-server:latest
```

#### Updating new version

You can force ECS to update service from ECS

```
aws ecs update-service --cluster yelb-cluster --service yelb-ui-service --force-new-deployment
```
