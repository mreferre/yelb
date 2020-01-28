This folder represents the customization of the Postgres database. There is no magic here. 

The Dockerfile basically builds off of the standard Postgres image and calls an init script that prepares the database structure (db and tables required by the Yelb application).  