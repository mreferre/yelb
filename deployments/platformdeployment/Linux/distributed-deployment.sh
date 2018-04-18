# These scripts deploy the yelb application across 4 different and separate cloud instances.
# Please make sure you set the proper variables included in each script. This is how each service will find the others (where applicable).
# Each instance should have the proper ports open to allow the communication flow (see main README for hints on ports)


# Run this script on the redis-server instance:

#!/bin/bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/redis-server.sh | bash 


# Run this script on the yelb-db instance:

#!/bin/bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-db.sh | bash


# Run this script on the yelb-appserver instance:

#!/bin/bash
export REDIS_SERVER_ENDPOINT=IP/FQDN-redis
export YELB_DB_SERVER_ENDPOINT=IP/FQDN-db
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-appserver.sh | bash


# Run this script on the yelb-ui instance:

#!/bin/bash
export YELB_APPSERVER_ENDPOINT=IP/FQDN-appserver
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-ui.sh | bash

