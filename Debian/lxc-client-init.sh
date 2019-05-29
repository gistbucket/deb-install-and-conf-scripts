sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen

[ "$(grep LC_ALL /etc/environment)" ] || echo 'LC_ALL="C"' >> /etc/environment
source /etc/environment
export LC_ALL

DEBIAN_FRONTEND=noninteractive
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
    haveged \
    lsb-release \
    unattended-upgrades \
    wget

systemctl enable haveged
systemctl start haveged

cp /usr/share/unattended-upgrades/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
sed -e 's|^//Unattended-Upgrade::AutoFixInterruptedDpkg.*;|Unattended-Upgrade::AutoFixInterruptedDpkg "true";|g' \
  -e 's|^//Unattended-Upgrade::MinimalSteps.*|Unattended-Upgrade::MinimalSteps "true";|g' \
  -e 's|^//Unattended-Upgrade::SyslogEnable.*|Unattended-Upgrade::SyslogEnable "true";|g' \
  -i /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's|^which=.*|which=both|g' /etc/apt/listchanges.conf

timedatectl set-timezone $(curl worldtimeapi.org/api/ip/$(curl ifconfig.io/ip)|cut -d\" -f16)
timedatectl set-ntp 1
