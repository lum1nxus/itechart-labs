#!/bin/bash

sudo mkdir /home/landing-page
sudo chmod -R 777 /home/landing-page
cd /tmp
sudo curl -sL https://rpm.nodesource.com/setup | bash -
sudo yum -y install nodejs gcc-c++ openssl-devel make java-11-openjdk-devel git
sudo npm install -g express-generator





