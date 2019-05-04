#!/bin/bash

# Massimo Re Ferre' massimo@it20.info

###########################################################
###########              USER INPUTS            ###########
###########################################################
# Variables AppServer component 
export RACK_ENV="${RACK_ENV:-custom}"
export REDIS_SERVER_ENDPOINT="${REDIS_SERVER_ENDPOINT:-localhost}"
export YELB_DB_SERVER_ENDPOINT="${YELB_DB_SERVER_ENDPOINT:-localhost}"
# If you want to connect to DDB you need to:
# set $YELB_DDB_RESTAURANTS / $YELB_DDB_CACHE / $AWS_REGION instead of $YELB_DB_SERVER_ENDPOINT / $REDIS_SERVER_ENDPOINT
###########################################################
###########           END OF USER INPUTS        ###########
###########################################################

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

echo "RACK_ENV = " $RACK_ENV
echo "REDIS_SERVER_ENDPOINT = " $REDIS_SERVER_ENDPOINT
echo "YELB_DB_SERVER_ENDPOINT = " $YELB_DB_SERVER_ENDPOINT
echo "YELB_DDB_RESTAURANTS = " $YELB_DDB_RESTAURANTS
echo "YELB_DDB_CACHE = " $YELB_DDB_CACHE
echo "AWS_REGION = " $AWS_REGION

cd $HOMEDIR
yum update -y
yum install -y ruby23
alternatives --set ruby /usr/bin/ruby2.3
yum install -y postgresql
yum install -y ruby23-devel
yum install -y gcc
yum install -y postgresql-devel
gem install pg --no-ri --no-rdoc
gem install redis --no-ri --no-rdoc
gem install sinatra --no-ri --no-rdoc
gem install aws-sdk-dynamodb --no-ri --no-rdoc
cd ./yelb/yelb-appserver
ruby yelb-appserver.rb -o 0.0.0.0 & 

