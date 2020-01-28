This script starts Yelb in development mode.

The workstation you are using must have a bunch of tools installed and ready to use (e.g. git, Docker, Ruby, angular@CLI, etc.).

Move to the directory where you want to work and clone the repo:

`git clone https://github.com/mreferre/yelb.git`

At this point you can start the script:

```
chmod +x yelb/deployments/localdevelopment/setupdevenv.sh
yelb/deployments/localdevelopment/setupdevenv.sh
```

You should now be able to see the application running by connecting your browser to: http://localhost:4200.

The source code is in the `yelb` folder. 

The yelb-ui angular instance and the yelb-appserver instance are started as background processes (use `ps` and `kill` as appropriate). The Redis server and the postgres database are started as containers. It is assumed that in the local development scenario only the appserver and the ui are being worked on.  

For the local development scenario the `RACK_ENV` variable is set to `development` and the `ng serve` command is explicitly started with the  `--environment=dev` flag.  

Also note that you can't really (easily) commit from here due to how the actual code is configured and assembled in the local development scenario as-is. This may be an area of optimization for the `dev` experience.

The start of the `yelb-ui` nginx and `yelb-appserver` Sinatra processes in background in the script provided is also another area of optimization. Easy to forget about them running in the background once done.   

All in all, the setup of the environment (specifically but not limited to all the ruby dependencies) is a good reason to consider using containers.