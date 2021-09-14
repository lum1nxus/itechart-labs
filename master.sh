#!/bin/bash
echo "Updating package lists"
sudo yum update -y
echo "Installing wget package"
sudo yum -y install wget git
echo "Installing repository link to the specified folder"
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
echo "Importing Jenkins public key"
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
echo "Upgrading package list"
sudo yum upgrade
echo "Installing Jenkins / OpenJDK"
sudo yum -y install epel-release java-1.8.0-openjdk-devel
sudo yum -y install jenkins 
echo "Reloading module files"
sudo systemctl daemon-reload
echo "Disabling the setup wizard from the Jenkins initialization"
sudo sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="-Djenkins.install.runSetupWizard=false --httpListenAddress=127.0.0.1"/' /etc/sysconfig/jenkins
echo "Copying groove scripts to init.groovy.d folder"
JENKINS_HOME=/var/lib/jenkins
sudo mkdir -p $JENKINS_HOME/init.groovy.d
for file in /vagrant/scripts/*
    do
        sudo cp $file $JENKINS_HOME/init.groovy.d
done
echo "Starting Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
172.16.1.50     MasterServer
172.16.1.51     SlaveServer
172.16.1.50     jenkins.itech.labs
EOF
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
sudo cp /vagrant/artifactory.lic $JFROG_HOME/artifactory/var/etc/artifactory
echo "Starting docker artifactory container"
sudo docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-pro:latest
echo  "Installing nodejs & npm"
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum -y install nodejs
var1=$(npm -version)
echo "npm version is $var1"
sudo mkdir -p /home/vagrant/project
cd /home/vagrant/project
sudo git init
sudo git remote add origin https://github.com/lum1nxus/project-examples.git
sudo git config core.sparseCheckout true
sudo bash -c 'echo "npm-example/*" > .git/info/sparse-checkout '
sudo git pull origin master
sudo npm config set unsafe-perm true
sudo jfrog config add Artifactory-Server --artifactory-url http://172.16.1.50:8081/artifactory --user luminxus --password 08052212 --interactive=false
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-local.json
{"key":"npm-local","packageType":"npm","rclass":"local"}
EOF'
sudo jfrog rt repo-create npm-local.json
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-remote.json
{"key":"npm-remote","packageType":"npm","rclass":"remote","url":"http://172.16.1.50:8081/artifactory/api/npm/npm-virtual"}
EOF'
sudo jfrog rt repo-create npm-remote.json
sudo bash -c 'cat << EOF > /home/vagrant/project/npm-virtual.json
{"key":"npm-virtual","packageType":"npm","rclass":"virtual","repositories":"npm-local,npm-remote"}
EOF'
sudo jfrog rt repo-create npm-virtual.json
sudo mkdir -p /home/vagrant/project/.jfrog/projects
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
sudo npm config set registry http://172.16.1.50:8081/artifactory/api/npm/npm-virtual
sudo yum -y install expect
sudo /usr/bin/expect <<EOD
spawn npm adduser
expect {
  "Username:" {send "luminxus\r"; exp_continue}
  "Password:" {send "08052212\r"; exp_continue}
  "Email: (this IS public)" {send "mrslavikhd@gmail.com\r"; exp_continue}
}
EOD
echo "Adding EPEL repository"
echo "Installing nginx & cert bot for ssl sertification"
sudo yum -y install nginx 
echo "Allowing nginx to connect to other services"
sudo setsebool -P httpd_can_network_connect on
echo "Starting nginx"
## If firewall is running
# sudo firewall-cmd --add-service=http
# sudo firewall-cmd --add-service=https
# sudo firewall-cmd --runtime-to-permanent
# sudo iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
# sudo iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/jenkins-selfsigned.key -out /etc/ssl/jenkins-selfsigned.crt -subj "/C=BY/ST=Minsk/L=Minsk/O=ITechArt/OU=ITDEP/CN=jenkins.itech.labs"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/artifactory-selfsigned.key -out /etc/ssl/artifactory-selfsigned.crt -subj "/C=BY/ST=Minsk/L=Minsk/O=ITechArt/OU=ITDEP/CN=artifactory.itech.labs"
sudo cp /vagrant/jenkins.conf /etc/nginx/conf.d
sudo cp /vagrant/artifactory.conf /etc/nginx/conf.d
sudo systemctl start nginx
sudo systemctl status nginx
sudo systemctl enable nginx







