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
echo "Starting Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
172.16.1.50     MasterServer
172.16.1.51     SlaveServer
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
sudo mkdir -p $JFROG_HOME/artifactory/var/etc/ 
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
echo "Starting docker artifactory container"
sudo docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-pro:latest



