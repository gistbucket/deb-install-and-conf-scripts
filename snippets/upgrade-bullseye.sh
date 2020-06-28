DISTRO="bullseye"

rm /etc/apt/sources.list

cat <<EOF > /etc/apt/sources.list.d/${DISTRO}.list
deb http://ftp.debian.org/debian ${DISTRO}-backports main contrib non-free
deb http://ftp.debian.org/debian ${DISTRO}-proposed-updates main contrib non-free
deb http://ftp.debian.org/debian ${DISTRO}-updates main contrib non-free
deb http://ftp.debian.org/debian ${DISTRO} main contrib non-free

deb http://security.debian.org/debian-security ${DISTRO}-security main contrib non-free
EOF

apt update
apt dist-upgrade -y
apt upgrade -y
reboot
