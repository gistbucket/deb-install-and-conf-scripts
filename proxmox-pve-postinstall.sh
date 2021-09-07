#!/usr/bin/env bash -eux

DEBIAN_FRONTEND=noninteractive

## VARIABLES
CPU="" # DEFAULT , OPTION amd or intel
MY_ZFS_ARC_MIN="" # Default set for 32GB - MY_ZFS_ARC_MIN=RAM_in_GB / 16 * 1073741824
MY_ZFS_ARC_MAX="" # Default set for 32GB - MY_ZFS_ARC_MAX=RAM_in_GB / 8 * 1073741824
# IF less than 16GB RAM
# MY_ZFS_ARC_MIN=1073741824
# MY_ZFS_ARC_MAX=1073741824

[[ "$(grep LC_ALL /etc/bash.bashrc)" ]] && \
cat <<EOF >> /etc/bash.bashrc
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
EOF

locale-gen en_US.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

[[ -z "$(grep force- /etc/dpkg/dpkg.cfg)" ]]  && \
cat <<EOF >> /etc/dpkg/dpkg.cfg
force-confold
force-confdef
EOF

echo -e "Acquire::ForceIPv4 \"true\";\\n" > /etc/apt/apt.conf.d/99force-ipv4

cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-community.list
sed "s/^deb/#deb/g" -i /etc/apt/sources.list.d/pve-enterprise.list
sed -e "s/pve-enterprise/pve-no-subscription/g" \
    -e "s/enterprise./download./g" \
    -e "s/https:/http:/g" -i /etc/apt/sources.list.d/pve-community.list
sed "s/main contrib/main non-free contrib/g" -i /etc/apt/sources.list

apt update
apt purge -y ntp openntpd chrony ksm-control-daemon
apt install -y byobu curl debian-archive-keyring debian-goodies etckeeper fail2ban ksmtuned ipset nano pigz unzip wget whois zfsutils zip
apt dist-upgrade -y

pveam update
systemctl enable ksmtuned
systemctl enable ksm

if [ "$(grep -i -m 1 "model name" /proc/cpuinfo | grep -i "EPYC")" != "" ]; then
  if ! grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub | grep -q "idle=nomwait" ; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="idle=nomwait /g' /etc/default/grub
    update-grub
  fi
  apt-get install -y pve-kernel-4.15
fi

[[ "$(grep -i -m 1 "model name" /proc/cpuinfo | grep -i "EPYC")" != "" ]] || [[ "$(grep -i -m 1 "model name" /proc/cpuinfo | grep -i "Ryzen")" != "" ]] && \
  echo "options kvm ignore_msrs=Y" >> /etc/modprobe.d/kvm.conf && \
  echo "options kvm report_ignored_msrs=N" >> /etc/modprobe.d/kvm.conf

apt autoremove -y
apt autoclean -y

systemctl disable rpcbind
systemctl stop rpcbind

timedatectl set-timezone $(curl -s worldtimeapi.org/api/ip/$(curl -s ifconfig.me/ip)|cut -d\" -f16)
cat <<EOF > /etc/systemd/timesyncd.conf
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF
service systemd-timesyncd start
timedatectl set-ntp true

cat <<EOF > /bin/pigzwrapper
#!/bin/sh
PATH=/bin:\$PATH
GZIP="-1"
exec /usr/bin/pigz "\$@"
EOF
mv -f /bin/gzip /bin/gzip.original
cp -f /bin/pigzwrapper /bin/gzip
chmod +x /bin/pigzwrapper
chmod +x /bin/gzip

[[ "$(whois -h v4.whois.cymru.com " -t $(curl ipinfo.io/ip 2> /dev/null)" | tail -n 1 | cut -d'|' -f3 | grep -i "ovh")" != "" ]] && \
  wget ftp://ftp.ovh.net/made-in-ovh/rtm/install_rtm.sh -c -O install_rtm.sh && bash install_rtm.sh && rm install_rtm.sh

cat <<EOF > /etc/fail2ban/filter.d/proxmox.conf
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
EOF

cat <<EOF > /etc/fail2ban/jail.d/proxmox.conf
[proxmox]
enabled = true
port = https,http,8006
filter = proxmox
logpath = /var/log/daemon.log
maxretry = 3
bantime = 3600 # 1 hour
EOF

cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
banaction = iptables-ipset-proto4
EOF
systemctl enable fail2ban

sed -i "s/#bwlimit:.*/bwlimit: 0/
        s/#pigz:.*/pigz: 1/
        s/#ionice:.*/ionice: 5/" /etc/vzdump.conf

cat <<EOF > /etc/security/limits.conf
* soft     nproc          256000
* hard     nproc          256000
* soft     nofile         256000
* hard     nofile         256000
root soft     nproc          256000
root hard     nproc          256000
root soft     nofile         256000
root hard     nofile         256000
EOF

cat <<EOF > /etc/sysctl.d/pve-tweak.conf
vm.swappiness=10
vm.min_free_kbytes=524288

fs.inotify.max_user_watches=1048576

# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Increase kernel max Key limit
kernel.keys.root_maxkeys=1000000
kernel.keys.maxkeys=1000000
EOF

echo 1048576 > /proc/sys/fs/inotify/max_user_watches
sed -i "s/^[#|]DefaultLimitNOFILE.*/DefaultLimitNOFILE=256000/" /etc/systemd/system.conf
sed -i "s/^[#|]DefaultLimitNOFILE.*/DefaultLimitNOFILE=256000/" /etc/systemd/user.conf

echo 'session required pam_limits.so' >> /etc/pam.d/common-session-noninteractive
echo 'session required pam_limits.so' >> /etc/pam.d/common-session
echo 'session required pam_limits.so' >> /etc/pam.d/runuser-l

echo "ulimit -n 256000" >> $HOME/.bashrc
echo "ulimit -n 256000" >> $HOME/.profile

cat <<EOF > /etc/modprobe.d/zfs.conf
options zfs zfs_arc_min=${MY_ZFS_ARC_MIN:-2147483648}
options zfs zfs_arc_max=${MY_ZFS_ARC_MAX:-4294967296}

options zfs l2arc_noprefetch=0
options zfs l2arc_write_max=524288000
EOF

update-initramfs -u -k all

## allow nesting
echo "options kvm-${CPU:-intel} nested=Y" > /etc/modprobe.d/kvm-${CPU:-intel}.conf

[[ -z $(grep iommu /etc/kernel/cmdline) ]] && \
sed -i "s/boot=zfs/boot=zfs ${CPU:-intel}_iommu=on/" /etc/kernel/cmdline && \
pve-efiboot-tool refresh



cat <<EOF > /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF

#loop
#virtio
#9p
#9pnet
#9pnet_virtio
#EOF
