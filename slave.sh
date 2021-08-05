#!/bin/bash

sudo yum -y install java-11-openjdk-devel
sudo mkdir /var/lib/swarm
cd /var/lib/swarm
sudo curl -O https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.27/swarm-client-3.27.jar
sudo cp /vagrant/autoconnect.service /etc/systemd/system
sudo systemctl enable /etc/systemd/system/autoconnect.service
sudo systemctl daemon-reload 
sudo systemctl restart /etc/systemd/system/autoconnect.service




