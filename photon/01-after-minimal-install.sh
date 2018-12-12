## downloadable via curl -LO https://git.io/fp2uF

DOMAIN=""
EMAIL="hostmaster@$DOMAIN"
USER=""
TZ=""

## install git
tdnf install -y git

[[ -n $DOMAIN ]] && \
cd /etc && \
git config --global user.email "$EMAIL"
git config --global user.name "root"
git init .
git add -A
git commit -m "FreshInstall"

## update
tdnf update -y

cd /etc
git add -A
git commit -m "update"

## install basic tools
tdnf install -y apparmor-profiles apparmor-utils haveged sudo wget

cd /etc
git add -A
git commit -m "basic tools"

## enable haveged
systemctl enable haveged
systemctl restart haveged

cd /etc
git add -A
git commit -m "enable haveged"

## config timezone
echo "Servers=0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org" >> /etc/systemd/timesyncd.conf
timedatectl set-timezone $TZ
timedatectl set-ntp 1

cd /etc
git add -A
git commit -m "set timezone"

## add user
groupmod -g 1000 users
sed "s|100|1000|g" -i /etc/default/useradd
useradd -mu 1000 -G users -s /bin/bash $USER
usermod -aG docker akeru
usermod -aG sshd akeru

cd /etc
git add -A
git commit -m "add user"

## config docker
[[ ! -f /etc/docker/daemon.json ]] && \
mkdir /etc/docker && \
echo -e '{
"experimental": false,
"live-restore": true,
"ipv6": false,
"no-new-privileges": false,
"userns-remap": "dockremap"
}' > /etc/docker/daemon.json

[[ -z $(grep dockremap /etc/passwd) ]] && \
groupadd -g 700 dockremap && \
useradd -Mu 700 -g 700 -s /bin/false dockremap && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f3):65536 >> /etc/subuid && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f4):65536 >> /etc/subgid

## install docker-compose
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chown root:docker /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl enable docker
systemctl restart docker

cd /etc
git add -A
git commit -m "config docker daemon"

reboot
