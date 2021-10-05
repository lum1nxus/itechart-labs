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
sudo sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="-Djenkins.install.runSetupWizard=false --httpListenAddress=0.0.0.0"/' /etc/sysconfig/jenkins
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
echo "Creating self-signed sertificate for jenkins"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/jenkins-selfsigned.key -out /etc/ssl/jenkins-selfsigned.crt -subj "/C=BY/ST=Minsk/L=Minsk/O=ITechArt/OU=ITDEP/CN=itechart.labs/jenkins"
echo "Creating self-signed sertificate for artifactory"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/artifactory-selfsigned.key -out /etc/ssl/artifactory-selfsigned.crt -subj "/C=BY/ST=Minsk/L=Minsk/O=ITechArt/OU=ITDEP/CN=itechart.labs/artifactory"
echo "Transfering config files"
sudo cp /vagrant/'nginx confs'/jenkins.conf /etc/nginx/conf.d
sudo cp /vagrant/'nginx confs'/artifactory.conf /etc/nginx/conf.d
echo "Starting nginx"
sudo systemctl start nginx
sudo systemctl status nginx
sudo systemctl enable nginx








