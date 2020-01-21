apt update
apt install -y libtext-iconv-perl
apt dist-upgrade -y

apt install -y \
    apt-listchanges apt-transport-https \
    ca-certificates coreutils curl \
    debian-goodies debsums dirmngr \
    gnupg \
    lsb-release \
    net-tools \
    unattended-upgrades \
    wget

timedatectl set-ntp 1
