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
yum -y install postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs
service postgresql initdb
#the seds below relaxe the postgres configuration to allow remote connectivity. This trades off security best practices for sake of deployment simplicity
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql9/data/postgresql.conf
sed -i "s/#port = 5432/port = 5432/" /var/lib/pgsql9/data/postgresql.conf
sed -i "s/peer/trust/" /var/lib/pgsql9/data/pg_hba.conf
sed -i "s/ident/trust/" /var/lib/pgsql9/data/pg_hba.conf
sed -i "s@host    all             all             127.0.0.1/32@host    all             all             0.0.0.0/0@" /var/lib/pgsql9/data/pg_hba.conf
service postgresql start
psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
    CREATE DATABASE yelbdatabase;
    \connect yelbdatabase;
		CREATE TABLE restaurants (
    	name        char(30),
    	count       integer,
    	PRIMARY KEY (name)
		);
		INSERT INTO restaurants (name, count) VALUES ('outback', 0);
		INSERT INTO restaurants (name, count) VALUES ('bucadibeppo', 0);
		INSERT INTO restaurants (name, count) VALUES ('chipotle', 0);
		INSERT INTO restaurants (name, count) VALUES ('ihop', 0);
EOSQL

