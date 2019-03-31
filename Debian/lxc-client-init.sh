#!/bin/bash

GitUserContent=https://raw.githubusercontent.com/jodumont/ConFig/master

### EN US UTF-8
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

### ETCKEEPER
apt install -y etckeeper
git config --global user.name "$(echo $USER)"
git config --global user.email "$(echo $USER)@$(hostname -s)"

### INSTALL TOOLS
apt remove --purge -y postfix
apt update
apt install -y \
    apt-listchanges apt-transport-https \
    ca-certificates coreutils curl \
    debian-goodies debsums dirmngr dnsutils \
    gnupg \
    haveged \
    iptables ipset \
    net-tools \
    socat sudo sysfsutils \
    unattended-upgrades \
    wget

### MORE ENTROPY
systemctl enable haveged
systemctl start haveged

### DEBIAN REPO
echo "deb http://deb.debian.org/debian/ $(lsb_release -sc) main contrib non-free
deb http://deb.debian.org/debian/ $(lsb_release -sc)-updates main contrib non-free
deb http://ftp.debian.org/debian $(lsb_release -sc)-backports main contrib non-free
deb http://deb.debian.org/debian-security $(lsb_release -sc)/updates main contrib non-free" > /etc/apt/sources.list

### EXTRA REPO
echo "deb https://packages.cisofy.com/community/lynis/deb/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/lynis.list
echo "deb [arch=amd64] http://mirror.23media.de/mariadb/repo/10.2/debian $(lsb_release -sc) main" > /etc/apt/sources.list.d/maria.list
echo "deb [arch=amd64] http://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/postgresql.list
echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
curl -fsSL http://www.webmin.com/jcameron-key.asc | apt-key add -

### DPKG & APT less interactive
echo "
force-confold
force-confdef
" > /etc/dpkg/dpkg.cfg

### UPGRADE
apt update
apt upgrade -y

### AUTOUPDATE
cp /usr/share/unattended-upgrades/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
sed -e 's|^//Unattended-Upgrade::AutoFixInterruptedDpkg.*;|Unattended-Upgrade::AutoFixInterruptedDpkg "true";|g' \
  -e 's|^//Unattended-Upgrade::MinimalSteps.*|Unattended-Upgrade::MinimalSteps "true";|g' \
  -e 's|^//Unattended-Upgrade::SyslogEnable.*|Unattended-Upgrade::SyslogEnable "true";|g' \
  -i /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's|^which=.*|which=both|g' /etc/apt/listchanges.conf

### SET TIMEZONE
timedatectl set-timezone $(curl worldtimeapi.org/api/ip/$(curl ifconfig.io/ip)|cut -d\" -f16)
timedatectl set-ntp 1

### AUTH-9286
sed 's|^PASS_MIN_DAYS.*|PASS_MIN_DAYS 7|g' -i /etc/login.defs
sed 's|^PASS_MAX_DAYS.*|PASS_MAX_DAYS 180|g' -i /etc/login.defs

### AUTH-9328
sed 's|^UMASK.*|UMASK 027|g' -i /etc/login.defs

### BANN-7126
curl -fsSLo /etc/issue ${GitUserContent}/etc/issue
curl -fsSLo /etc/issue.net ${GitUserContent}/etc/issue

### BLACKLIST
curl -fsSLo etc/modprobe.d/blacklist_bluetooth ${GitUserContent}etc/modprobe.d/blacklist_bluetooth
curl -fsSLo etc/modprobe.d/blacklist_network ${GitUserContent}etc/modprobe.d/blacklist_network
curl -fsSLo etc/modprobe.d/blacklist_others ${GitUserContent}etc/modprobe.d/blacklist_others
curl -fsSLo etc/modprobe.d/blacklist_thunderbold ${GitUserContent}etc/modprobe.d/blacklist_thunderbold

#### FILE-6430
modprobe -r cramfs
modprobe -r freevxfs hfs hfsplus jffs2 squashfs udf
curl -fsSLo /etc/modprobe.d/blacklist_filesystem ${GitUserContent}/etc/modprobe.d/blacklist_filesystem

#### STRG-1840, 1841, 1842
modprobe -r usb-storage
curl -fsSLo /etc/modprobe.d/blacklist_usb ${GitUserContent}/etc/modprobe.d/blacklist_usb

#### STRG-1846
modprobe -r firewire-core firewire_ohci
curl -fsSLo /etc/modprobe.d/blacklist_firewire ${GitUserContent}/etc/modprobe.d/blacklist_firewire

### IPv6
[[ ${noIPv6} == "Y|y|YES|Yes|yes" ]] \
&& curl -fsSLo /etc/sysctl.d/noIPv6.conf ${GitUserContent}/etc/sysctl.d/noIPv6.conf

### KRNL-6000
curl -fsSLo /etc/sysctl.d/fs.conf ${GitUserContent}/etc/sysctl.d/fs.conf
curl -fsSLo /etc/sysctl.d/kernel.conf ${GitUserContent}/etc/sysctl.d/kernel.conf
curl -fsSLo /etc/sysctl.d/ipv4.conf ${GitUserContent}/etc/sysctl.d/ipv4.conf
curl -fsSLo /etc/sysctl.d/ipv6.conf ${GitUserContent}/etc/sysctl.d/ipv6.conf

### MODULI & SSH
curl -fsSLo /etc/ssh/sshd_config ${GitUserContent}/etc/ssh/sshd_config

### REDIS
curl -fsSLo /etc/sysfs.conf ${GitUserContent}/etc/sysfs.conf
curl -fsSLo /etc/sysctl.d/redis.conf ${GitUserContent}/etc/sysctl.d/redis.conf

### SHLL-6220
echo -e "
# set a 5 min timeout policy for bash shell
TMOUT=300
readonly TMOUT
export TMOUT" >> /etc/profile

reboot
