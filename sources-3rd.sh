#!/bin/bash -eux

OS=$(lsb_release -s -i)
VERSION=$(lsb_release -s -c)

## ADAPTA THEME
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys EAC0D406E5D79A82ADEEDFDFB76E53652D87398A
echo "deb http://ppa.launchpad.net/tista/adapta/${OS,,} $VERSION main" > /etc/apt/sources.list.d/adapta.list

## DEB MULTIMEDIA
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
echo "deb [arch=amd64] https://www.deb-multimedia.org $VERSION main non-free" > /etc/apt/sources.list.d/deb-multimedia.list

## DOCKER
curl -fsSL https://download.docker.com/linux/${OS,,}/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/${OS,,} $VERSION stable" > /etc/apt/sources.list.d/docker.list

## GOOGLE
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

## MARIADB
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
echo "deb [arch=amd64] http://mirror.23media.de/mariadb/repo/10.2/${OS,,} $VERSION main" > /etc/apt/sources.list.d/mariadb.list

### NGINX
wget https://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key
echo "deb [arch=amd64] http://nginx.org/packages/${OS,,} $VERSION nginx" > /etc/apt/sources.list.d/nginx.list

## NODEJS
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo "deb https://deb.nodesource.com/node_12.x $VERSION main" > /etc/apt/sources.list.d/nodejs.list

## PHP
wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
echo "deb https://packages.sury.org/php/ $VERSION main" > /etc/apt/sources.list.d/php.list

## POSTGRESQL
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $VERSION-pgdg main" > /etc/apt/sources.list.d/postgres.list

## SKYPE
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1F3045A5DF7587C3
echo "deb [arch=amd64] https://repo.skype.com/deb stable main" > /etc/apt/sources.list.d/skype.list

## TEAMVIEWER
wget -O - https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | apt-key add -
echo "deb http://linux.teamviewer.com/deb stable main" > /etc/apt/sources.list.d/teamviewer.list

## VSCODE
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

apt update
apt upgrade -y
