# this series of scripts deploys the yelb application across 4 different and separate cloud instances
# please make sure you set the proper variables included in each script
# each instance should have the proper ports open to allow the communication flow 


# Run this script on the redis-server instance:

#!/bin/bash
curl https://gist.githubusercontent.com/mreferre/46613d0e89af8527130ba5008ed18974/raw/yelb-redis.sh | bash 


# Run this script on the yelb-db instance:

#!/bin/bash
curl https://gist.githubusercontent.com/mreferre/2001b99ed163103bf4c90aee87be1c7b/raw/yelb-db.sh | bash


# Run this script on the yelb-appserver instance:

#!/bin/bash
export REDIS_SERVER_ENDPOINT=IP/FQDN-redis
export YELB_DB_SERVER_ENDPOINT=IP/FQDN-db
curl https://gist.githubusercontent.com/mreferre/27c85452ea264f25ed1f63952d3cf61b/raw/yelb-appserver.sh | bash


# Run this script on the yelb-ui instance:

#!/bin/bash
export YELB_APPSERVER_ENDPOINT=IP/FQDN-appserver
curl https://gist.githubusercontent.com/mreferre/09d298c53d28d99c4924c405425b4b8b/raw/yelb-ui.sh | bash

