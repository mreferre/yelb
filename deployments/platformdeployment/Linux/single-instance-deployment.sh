# This script deploys the yelb application on a single cloud instance.
# It is enough to open port 80 on this instance and connect to its IP/FQDN.
# Note some of these scripts require you to input the proper endpoints. 
# However these scripts have a default to "localhost" should no variable be set, so they by default works on a single instance deployment.

#!/bin/bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/redis-server.sh | bash 
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-db.sh | bash
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-appserver.sh | bash
export YELB_APPSERVER_ENDPOINT=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
curl https://raw.githubusercontent.com/mreferre/yelb/master/deployments/platformdeployment/Linux/yelb-ui.sh | bash 

