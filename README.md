## Installation guide
### 1. Vagrant
1. Go to cloned repository and start vagrant by typing vagrant up in Bash.
### 2. Jenkins
1. Create a user with credentials from slave.sh
2. Install Publish over SSH, Swarm, Github, Pipeline plugins.
3. Fill out the Publish over SSH form in system configuration.
   * Add vagrant user private key from DeployServer.
   * Add DeployServer hostname.
   * Remote Directory is /
>If it doesnt work, try `cat id_rsa.pub >> authorized_keys`

4. Add git path in configure tools. Usually its /usr/bin/git.
5. Open static port:50000 for inbound agents in configure tools.
6. Add jenkins user public key from MasterServer to Github.
7. Add jenkins user private key from MasterServer to credentials, type username that used on Github.
## 3. Freestyle Job
1. Add project url of Github project.
2. Activate deletion of past builds.
3. Activate Git and add repository url (SSH preferably), add Github credentials.
4. In postbuild operations choose Publish over SSH.
   * Add your SSH server configured before.
   * Source files are '**/*'
   * Remote directory is /home... if you dont have rights, `chmod -R 777 /home...`
   * Exec commands are cd /home/cosmic `sudo npm install sudo npm install express hogan-express http-errors debug morgan jade cookie-parser cosmicjs sudo yarn start`
## 4. Pipeline
1. Add project url of Github project.
2. Activate deletion of past builds.
3. Add pipeline script from Jenkinsfile.
