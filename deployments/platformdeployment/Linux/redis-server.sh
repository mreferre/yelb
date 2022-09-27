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

amazon-linux-extras install epel -y
yum update -y
yum install redis -y
sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis.conf
sed -i "s/protected-mode yes/protected-mode no/" /etc/redis.conf
systemctl enable redis
systemctl start redis