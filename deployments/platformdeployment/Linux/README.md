These scripts had been tested only on Amazon Linux instances for now. Other Linux distributions will likely not work for now. Ideally all the part that is OS related (e.g. setup of NodeJS to compile the Angular application, setup of Ruby, etc.) should be managed via a change management technology (such as Puppet, Ansible, etc.). This will avoid having either many of OS-specific scripts or few very complex scripts that deal with Linux distributions peculiarities. 

This problem has been resolved already in the industry and these scripts should leverage that to scale the distros supported. 

Also, consider that some of these scripts seem to be working only if you explicitly login with the user `root`. Some will work with sudo/su but some require that you actually login as `root`. If you run these scripts at startup via `cloud-init` it is fine as you are running the scripts with the user `root`.  

This is a work in progress.
