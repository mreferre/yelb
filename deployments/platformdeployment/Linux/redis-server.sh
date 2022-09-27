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
systemctl enable redis
systemctl start redis