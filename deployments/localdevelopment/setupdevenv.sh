
#!/bin/bash

# workstation requirements: git, Docker, Ruby (with proper libraries/gems), angular@CLI 

docker run --name redis -p 6379:6379 -d redis:4.0.2
docker run --name postgres -p 5432:5432 -d mreferre/yelb-db:0.5

cd ./yelb/yelb-appserver
export RACK_ENV=development 
ruby yelb-appserver.rb & # this can be shut down with the kill command 

cd ../yelb-ui

# for the time being the clarity seed is cloned from master, as specific commit is checked out 
# and the modified files from the yelb projects are added or replaced.  

git clone https://github.com/vmware/clarity-seed.git
cd clarity-seed
git checkout -b f3250ee26ceb847f61bb167a90dc957edf6e7f43

cp ../clarity-seed-newfiles/src/index.html src/index.html
cp ../clarity-seed-newfiles/src/styles.css src/styles.css
cp ../clarity-seed-newfiles/src/app/app* src/app
cp ../clarity-seed-newfiles/src/environments/env* src/environments
cp ../clarity-seed-newfiles/package.json package.json
cp ../clarity-seed-newfiles/angular-cli.json .angular-cli.json
rm -r src/app/home
rm -r src/app/about

npm install 
ng serve --port 4200 --environment=dev & # this can be shut down with the kill command

cd ..


# connect your browser to: http://localhost:4200 
# edit the source code in the yelb folder



