#!/bin/bash

# Massimo Re Ferre' massimo@it20.info

###########################################################
###########            CORE HOUSEKEEPING        ###########
###########################################################
export HOMEDIR="/yelb-setup"
yum update -y 
yum install -y git
if [ ! -d $HOMEDIR ]; then
    mkdir $HOMEDIR
    cd $HOMEDIR
    git clone http://github.com/mreferre/yelb
fi 
###########################################################

cd $HOMEDIR
yum -y install gcc64 gcc-c++ make jemalloc-devel
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
cp src/redis-server /usr/bin/
cp src/redis-cli /usr/bin/
#the script below configures the redis service
REDIS_PORT=6379 \
    REDIS_CONFIG_FILE=/etc/redis/6379.conf \
    REDIS_LOG_FILE=/var/log/redis_6379.log \
    REDIS_DATA_DIR=/var/lib/redis/6379 \
    REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh
#the commands below configure redis to accept remote connections
service redis_6379 stop
sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/6379.conf
service redis_6379 start
