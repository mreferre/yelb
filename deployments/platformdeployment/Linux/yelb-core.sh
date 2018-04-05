#!/bin/bash

# Massimo Re Ferre' massimo@it20.info

export HOMEDIR="/yelb-setup"

mkdir $HOMEDIR
cd $HOMEDIR
yum update -y 
yum install -y git
git clone http://github.com/mreferre/yelb