This is a sample which uses [AWS Copilot](https://aws.amazon.com/containers/copilot/) for deploying
the Yelb application. Each component of Yelb is represented as a separate service in the Copilot
config (svcname/manifest.yml).

```
$ copilot svc ls --app yelb
Name                Type
--------------      -------------------------
redis-server        Backend Service
yelb-appserver      Backend Service
yelb-db             Backend Service
yelb-ui             Load Balanced Web Service
```
