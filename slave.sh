#!/bin/bash

sudo yum -y install java-11-openjdk-devel
sudo mkdir /var/lib/swarm
cd /var/lib/swarm
sudo curl -O https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.27/swarm-client-3.27.jar
sudo java -jar /home/vagrant/swarm-client-3.27.jar -disableSslVerification -url http://172.16.1.50:8080 -username luminxus -password 08052212


