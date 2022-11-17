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
To apply changes to AWS use `terraform apply`. It will print changes it is going to make to cloud and prompts for your confirmation. If making changes just run apply again.

When its done it outputs our loadbalancer URL which we can use to start application in browser.

When you want to destroy your AWS setup run `terraform destroy`.

Terraform keeps the state of your deployment in a file called `terraform.tfstate` and `terraform.lock.hcl` which will appear after `apply` command. So keep these files locally around.

```
#### Updating new version

You can force ECS to update service from images

```

aws ecs update-service --cluster yelb-cluster --service yelb-ui-service --force-new-deployment

```

```
