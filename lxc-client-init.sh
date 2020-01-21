[ "$(grep LC_ALL /etc/bash.bashrc)" ] || echo -e '
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL="C"
' >> /etc/bash.bashrc

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C
locale-gen en_US.UTF-8

[ "$(grep force- /etc/dpkg/dpkg.cfg)" ] || echo -e "
force-confold
force-confdef
" >> /etc/dpkg/dpkg.cfg

apt update
apt install -y libtext-iconv-perl
apt dist-upgrade -y
apt install -y \
    apt-listchanges apt-transport-https \
    ca-certificates coreutils curl \
    debian-goodies debsums \
    gnupg \
    lsb-release \
    net-tools \
    unattended-upgrades \
    wget

cp /usr/share/unattended-upgrades/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
sed -e 's|^//Unattended-Upgrade::AutoFixInterruptedDpkg.*;|Unattended-Upgrade::AutoFixInterruptedDpkg "true";|g' \
  -e 's|^//Unattended-Upgrade::MinimalSteps.*|Unattended-Upgrade::MinimalSteps "true";|g' \
  -e 's|^//Unattended-Upgrade::SyslogEnable.*|Unattended-Upgrade::SyslogEnable "true";|g' \
  -i /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's|^which=.*|which=both|g' /etc/apt/listchanges.conf

timedatectl set-timezone $(curl worldtimeapi.org/api/ip/$(curl ifconfig.io/ip)|cut -d\" -f16)
timedatectl set-ntp 1
