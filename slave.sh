#!/bin/bash

echo "Installing java & git"
sudo yum -y install java-1.8.0-openjdk-devel git
echo "Installing swarm client to connect slave and master"
sudo mkdir -p /var/lib/swarm
cd /var/lib/swarm
sudo curl -O https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.27/swarm-client-3.27.jar
echo "Transfering autoconnect service"
sudo cp /vagrant/autoconnect.service /etc/systemd/system
echo "Enabling autoconnect service"
sudo systemctl enable /etc/systemd/system/autoconnect.service
sudo systemctl daemon-reload 
sudo systemctl restart autoconnect

## Command to download jenkins cli
# sudo curl http://172.16.1.50:8080/jnlpJars/jenkins-cli.jar > jenkins-cli.jar

echo "Installing yum-utils"
sudo yum -y install yum-utils
echo "Adding docker repository"
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io
echo "Enabling and starting docker"
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
echo "Creating specified directories for artifactory"
sudo mkdir /opt/jfrog
export JFROG_HOME=/opt/jfrog
sudo mkdir -p $JFROG_HOME/artifactory/var/etc/artifactory
sudo mkdir -p /var/opt/jfrog/artifactory/
echo "Creating yaml file"
cd $JFROG_HOME/artifactory/var/etc/
sudo touch ./system.yaml
sudo bash -c 'cat << EOF > /opt/jfrog/artifactory/var/etc/system.yaml
shared:
    node:
        ip: 172.16.1.50
EOF'
echo "Changing owner to 1030(artifactory user id)"
sudo chown -R 1030:1030 $JFROG_HOME/artifactory/var
sudo chown -R 1030:1030 /var/opt/jfrog/artifactory/
echo "Changing access permissions to 777"
sudo chmod -R 777 $JFROG_HOME/artifactory/var
echo "Creating admin user credits"
sudo mkdir -p $JFROG_HOME/artifactory/var/etc/access
sudo bash -c 'cat << EOF > /opt/jfrog/artifactory/var/etc/access/bootstrap.creds
luminxus@*=08052212
EOF'
echo "Giving a file revelant permissions"
sudo chmod 600 /opt/jfrog/artifactory/var/etc/access/bootstrap.creds
sudo chown -R 1030:1030 $JFROG_HOME/artifactory/var/etc/access
echo "Inserting license key"
sudo cp /vagrant/artifactory/artifactory.lic $JFROG_HOME/artifactory/var/etc/artifactory
echo "Inserting artifactory xml config for anonymous access"
sudo cp /vagrant/artifactory/artifactory.config.xml $JFROG_HOME/artifactory/var/etc/artifactory
echo "Starting docker artifactory container"
sudo docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-pro:latest
echo  "Installing nodejs & npm"
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum -y install nodejs
var1=$(npm -version)
echo "npm version is $var1"
sudo mkdir -p /home/vagrant/project
cd /home/vagrant/project
echo "Downloading npm project example"
sudo git init
sudo git remote add origin https://github.com/lum1nxus/project-examples.git
sudo git config core.sparseCheckout true
sudo bash -c 'echo "npm-example/*" > .git/info/sparse-checkout '
sudo git pull origin master

# NPM doesnt work without unsafe-perm true config
sudo npm config set unsafe-perm true
echo "Adding url to jfrog config"
sudo jfrog config add Artifactory-Server --artifactory-url http://172.16.1.50:8081/artifactory --user luminxus --password 08052212 --interactive=false
echo "Creating local.json example"
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-local.json
{"key":"npm-local","packageType":"npm","rclass":"local"}
EOF'
sudo jfrog rt repo-create npm-local.json
echo "Creating remote.json example"
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-remote.json
{"key":"npm-remote","packageType":"npm","rclass":"remote","url":"http://172.16.1.50:8081/artifactory/api/npm/npm-virtual"}
EOF'
sudo jfrog rt repo-create npm-remote.json
echo "Creating virtual.json example"
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-virtual.json
{"key":"npm-virtual","packageType":"npm","rclass":"virtual","repositories":"npm-local,npm-remote"}
EOF'
sudo jfrog rt repo-create npm-virtual.json
sudo mkdir -p /home/vagrant/project/.jfrog/projects
echo "Creating npm yaml file"
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-example/.jfrog/projects/npm.yaml
version: 1
type: npm
resolver:
  repo: npm-virtual
  serverId: Artifactory-Server
deployer:
  repo: npm-virtual
  serverId: Artifactory-Server
EOF'
echo "Setting npm registry"
sudo npm config set registry http://172.16.1.50:8081/artifactory/api/npm/npm-virtual
sudo yum -y install expect
## If inserted xml works right, no need in adduser/login
# sudo /usr/bin/expect <<EOD
# spawn npm adduser
# expect {
#   "Username:" {send "luminxus\r"; exp_continue}
#   "Password:" {send "08052212\r"; exp_continue}
#   "Email: (this IS public)" {send "mrslavikhd@gmail.com\r"; exp_continue}
# }
# EOD


