### Terraform configs

- Creates own VPC
- One service
- One task with all containers
- Only public endpoint is the ALB
- Communicates via AWS VPC networking using localhost only (fast and secure)
- No nameserver needed
- CloudWatch logs

NOTE: Container images tags are specified in ecs.tf and are (ideally) kept up to date.

Using "RACK_ENV=custom" we can specify custom endpoints for the Postgres database and the Redis server.
AWS VPC networking allows the containers inside same task to talk each other via `localhost` (which is what we set the Postgres and Redis endpoint variables to). This is done in the `./templates/ecs/yelb_app.json.tpl` file.

### AWS region

AWS region is taken from AWS profile, make sure you have set it in .aws/config file:
example:

```
[default]
region = eu-central-1
```

### Terraform init

Use `terraform init` once, it will create terraform working environment here.
To apply the changes use `terraform apply`. It will print changes it is going to make to cloud and prompts for your confirmation. If you are making further changes just run apply again.

When it's done it outputs our load balancer URL which we can use to test the application in the browser.

When you want to destroy your AWS setup run `terraform destroy`.

Terraform keeps the state of your deployment in a file called `terraform.tfstate` and `terraform.lock.hcl` which will appear after `apply` command. So keep these files locally around.