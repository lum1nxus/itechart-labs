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
echo "Disabling the setup wizard from the Jenkins initialization"
sudo sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="-Djenkins.install.runSetupWizard=false"/' /etc/sysconfig/jenkins
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
172.16.1.50     MasterServer
172.16.1.51     SlaveServer
EOF
sudo yum -y install yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl status docker
sudo mkdir /opt/jfrog
JFROG_HOME=/opt/jfrog
sudo mkdir -p $JFROG_HOME/artifactory/var/etc/
cd $JFROG_HOME/artifactory/var/etc/
sudo touch ./system.yaml
sudo chown -R 1030:1030 $JFROG_HOME/artifactory/var
sudo chmod -R 777 $JFROG_HOME/artifactory/var
sudo bash -c 'cat << EOF > /opt/jfrog/artifactory/var/etc/system.yaml
shared:
    node:
        ip: 172.16.1.50
EOF'
sudo docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-pro:latest


