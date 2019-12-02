## REQUIREMENT DOCKER INSTALL

apt-get remove --purge -y docker docker-engine docker.io
apt-get install -y \
     apt-transport-https \
     ca-certificates curl \
     gnupg2 \
     software-properties-common

## PRECONFIG DOCKER-DAEMON

mkdir /etc/docker
echo -e '{
  "data-root": "/home/docker",
  "dns": ["1.1.1.1", "1.0.0.1"],
  "experimental": false,
  "log-driver": "journald",
  "no-new-privileges": false
}' > /etc/docker/daemon.json

## INSTALL DOCKER

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt-get install -y docker-ce
apt remove --purge -y aufs*
apt autoremove --purge -y

## INSTALL DOCKER-COMPOSE

curl -L https://github.com/docker/compose/releases/download/$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | awk -F '"' '/tag_name/{print $4}')/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
