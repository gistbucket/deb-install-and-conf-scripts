
apt purge -y \
  btrfs-progs btrfs-tools \
  cryptsetup cryptsetup-bin \
  dmsetup \
  eatmydata \
  lxcfs lxd lxd-client lvm2 \
  mdadm \
  ntfs-3g \
  open-iscsi \
  snapd \
  telnet \
  xfsprogs

apt update
apt dist-upgrade -y

apt install -y \
  apt-listchanges apt-transport-https \
  byobu \
  ca-certificates coreutils curl \
  debian-goodies debsums \
  gnupg \
  lsb-release linux-generic-hwe-18.04 \
  unattended-upgrades \
  wget

systemctl reset-failed
timedatectl set-ntp 1


#apt remove --purge -y *$(ls /lib/modules/|grep -v $(uname -a|cut -d' ' -f3))*
#apt autoremove --purge -y
