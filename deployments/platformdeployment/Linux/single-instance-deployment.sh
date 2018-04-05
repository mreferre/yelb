# this scripts deploys the yelb application on a single cloud instance
# it is enough to open port 80 on this instance and connect to its IP/FQDN 

#!/bin/bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/redis-server.sh | bash 
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-db.sh | bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-appserver.sh | bash
export YELB_APPSERVER_ENDPOINT=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-ui.sh | bash 

