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
sudo yum -y install jenkins java-11-openjdk-devel
echo "Reloading module files"
sudo systemctl daemon-reload
echo "Disabling the setup wizard from the Jenkins initialization"
sudo sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="-Djenkins.install.runSetupWizard=false"/' /etc/sysconfig/jenkins
echo "Copying groove scripts to init.groovy.d folder"
JENKINS_HOME=/var/lib/jenkins
sudo mkdir -p $JENKINS_HOME/init.groovy.d
for file in /vagrant/scripts/*
    do
        sudo cp $file $JENKINS_HOME/init.groovy.d
done
email=prodluminxus@gmail.com
githubuser=luminxus
githubpass=13169909Slava
if [ ! -f ~/.ssh/id_rsa ]; then
ssh-keygen -t rsa -b 4096 -C "$email"
ssh-add ~/.ssh/id_rsa
fi
pub=`cat ~/.ssh/id_rsa.pub`
curl -u "$githubuser:$githubpass" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$pub\"}" https://api.github.com/user/keys
echo "Starting Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
172.16.1.50     MasterServer
172.16.1.51     SlaveServer
EOF



