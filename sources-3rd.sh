apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys EAC0D406E5D79A82ADEEDFDFB76E53652D87398A
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
wget -q -O - http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/Release.key | apt-key add -
wget https://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1F3045A5DF7587C3
wget -O - https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | apt-key add -
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

###Adapta GTK Theme
echo "deb http://ppa.launchpad.net/tista/adapta/ubuntu bionic main" > /etc/apt/sources.list.d/adapta.list

###Debian Multimedia
echo "deb [arch=amd64] https://www.deb-multimedia.org buster main non-free" > /etc/apt/sources.list.d/deb-multimedia.list

###Docker CE
echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" > /etc/apt/sources.list.d/docker-ce.list

###Google Chrome Browser
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

###MariaDB
echo "deb [arch=amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main" > /etc/apt/sources.list.d/mariadb.list

###nginx
echo "deb [arch=amd64] http://nginx.org/packages/debian/ buster nginx" > /etc/apt/sources.list.d/nginx.list

###NodeJs
echo "deb https://deb.nodesource.com/node_12.x buster main" > /etc/apt/sources.list.d/nodejs.list

###PHP
echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list

###Skype
echo "deb [arch=amd64] https://repo.skype.com/deb stable main" > /etc/apt/sources.list.d/skype.list

###Teamviewer
echo "deb http://linux.teamviewer.com/deb stable main" > /etc/apt/sources.list.d/teamviewer.list

###Visual Studio Code
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

apt update
apt upgrade -y
