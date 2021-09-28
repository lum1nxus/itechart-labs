#!/bin/bash

echo "Installing all necessary stuff"
sudo yum -y install gcc-c++ make openssl-devel java-1.8.0-openjdk-devel git
echo "Cloning app"
sudo git clone https://github.com/tonyspiro/react-universal-blog
echo "Installing nodejs"
sudo curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash - 
sudo yum -y install nodejs 
echo "Adding yarn repo"
sudo curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
echo "Installing yarn"
sudo yum -y install yarn
echo "Installing nginx & cert bot for ssl sertification"
sudo yum -y install epel-release nginx 
echo "Allowing nginx to connect to other services"
sudo setsebool -P httpd_can_network_connect on
echo "Starting nginx"
cd react-universal-blog
echo "Installing packages"
sudo npm install
echo "Transfering universal configuration file"
sudo cp /vagrant/universal.conf /etc/nginx/conf.d
echo "Starting nginx"
sudo systemctl start nginx
sudo systemctl status nginx
sudo systemctl enable nginx






