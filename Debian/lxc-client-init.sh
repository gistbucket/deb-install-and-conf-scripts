### EN US UTF-8
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

apt remove --purge -y postfix
apt update
apt install -y \
    apt-listchanges apt-transport-https \
    ca-certificates coreutils curl \
    debian-goodies debsums \
    gnupg \
    haveged \
    unattended-upgrades \
    wget

### MORE ENTROPY
systemctl enable haveged
systemctl start haveged

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

reboot
