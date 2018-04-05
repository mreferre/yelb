# this scripts deploys the yelb application on a single cloud instance
# it is enough to open port 80 on this instance and connect to its IP/FQDN 

#!/bin/bash
curl https://gist.githubusercontent.com/mreferre/46613d0e89af8527130ba5008ed18974/raw/yelb-cache.sh | bash 
curl https://gist.githubusercontent.com/mreferre/2001b99ed163103bf4c90aee87be1c7b/raw/yelb-db.sh | bash
curl https://gist.githubusercontent.com/mreferre/27c85452ea264f25ed1f63952d3cf61b/raw/yelb-appserver.sh | bash
export YELB_APPSERVER_ENDPOINT=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
curl https://gist.githubusercontent.com/mreferre/09d298c53d28d99c4924c405425b4b8b/raw/yelb-ui.sh | bash 

