This script starts Yelb in a local `test` environment (leveraging containers). 

The workstation you are using doesn't have any prerequisit (except for `Docker`).

You can either `docker-compose up` the yaml file provided in this folder or, alternatively, you can run these commands manually to stand up the environment :

```
docker network create yelb-network 
docker run --name redis-server -p 6379:6379 --network=yelb-network -d redis:4.0.2
docker run --name yelb-db -p 5432:5432 --network=yelb-network -d mreferre/yelb-db:0.5
docker run --name yelb-appserver --network=yelb-network -d -p 4567:4567 -e RACK_ENV=test mreferre/yelb-appserver:0.5
docker run --name yelb-ui --network=yelb-network -d -p 8080:80 -e UI_ENV=test mreferre/yelb-ui:0.7
```
You should now be able to see the application running by connecting your browser to: http://localhost:8080

In this local test scenario all services are exposed on their ports and they are all referenced with `localhost:<port>`. In this scenario there is no need for name resolutions and service discovery (everything is resolved as `localhost`). 

Note that for the local test scenario we need to force the `RACK_ENV` variable to `test` and the `UI_ENV` variable to `test`. Their default is respectively `production` and `prod`. 