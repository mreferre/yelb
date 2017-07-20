#!/bin/bash
NGINX_CONF=/etc/nginx/conf.d/default.conf
cd clarity-seed

sed -i -- 's#/usr/share/nginx/html#/clarity-seed/'$UI_ENV'/dist#g' $NGINX_CONF

# this adds the reverse proxy configuration to nginx 
# everything that hits /api is proxied to the app server     
if ! grep -q "location /api" "$NGINX_CONF"; then
	echo "    location /api {" > /proxycfg.txt
	echo "        proxy_pass http://yelb-appserver:4567/api;" >> /proxycfg.txt
	# echo "        proxy_set_header Host $host;" >> /proxycfg.tx
	echo "    }" >> /proxycfg.txt
	sed --in-place '/server_name  localhost;/ r /proxycfg.txt' $NGINX_CONF
fi
nginx -g "daemon off;" 


