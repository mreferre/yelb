
#!/bin/bash

# workstation requirements: git, Docker, Ruby (with proper libraries/gems), angular@CLI 

docker run --name redis -p 6379:6379 -d redis:4.0.2
docker run --name postgres -p 5432:5432 -d fauh45/yelb-db:v1

cd ./yelb/yelb-appserver
export RACK_ENV=development 

bundle install

sudo gem install sinatra
sudo gem install aws-sdk-dynamodb

ruby yelb-appserver.rb & # this can be shut down with the kill command 

cd ../yelb-ui/clarity-seed

# for the time being the clarity seed is cloned from master, as specific commit is checked out 
# and the modified files from the yelb projects are added or replaced.  

npm install
npx ng serve --port 4200 --environment=dev & # this can be shut down with the kill command

cd ..

# connect your browser to: http://localhost:4200 
# edit the source code in the yelb folder
