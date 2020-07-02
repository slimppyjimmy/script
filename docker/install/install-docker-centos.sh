sudo yum update
reboot

rpm -qa | grep docker

sudo yum remove docker  docker-common docker-client

sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum list docker-ce --showduplicates | sort -r
sudo yum install docker-ce 
sudo systemctl start docker
docker version
sudo systemctl enable docker
