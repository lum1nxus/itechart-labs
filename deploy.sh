#!/bin/bash


sudo mkdir /home/landing-page
sudo chmod -R 777 /home/landing-page
sudo yum -y install gcc-c++ make openssl-devel java-11-openjdk-devel git
sudo curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash - 
sudo yum -y install nodejs 
sudo curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
sudo yum -y install yarn
cd /tmp
sudo curl -sL https://rpm.nodesource.com/setup | bash -
sudo npm install -g express-generator





