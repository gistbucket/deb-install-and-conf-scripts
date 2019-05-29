apt update
apt -o Dpkg::Options::="--force-confold" -y --force-yes install libtext-iconv-perl 

                    
[ "$(grep LC_ALL /etc/bash.bashrc)" ] || echo -e '
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8' >> /etc/bash.bashrc

[ "$(grep LC_ALL /etc/environment)" ] || echo "LC_ALL=en_US.UTF-8" >> /etc/environment
[ "$(grep LC_ALL /etc/locale.conf)" ] || echo "LANG=en_US.UTF-8" > /etc/locale.conf
[ "$(grep LC_ALL /etc/locale.gen)" ] || echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen






export LANGUAGE=en_US.UTF-8
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
