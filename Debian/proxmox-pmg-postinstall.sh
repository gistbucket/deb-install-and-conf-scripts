#!/usr/bin/env bash

export LANG="en_US.UTF-8"
export LC_ALL="C"

echo -e "Acquire::ForceIPv4 \"true\";\\n" > /etc/apt/apt.conf.d/99force-ipv4

[[ -f /etc/apt/sources.list.d/pmg-enterprise.list ]] && \
cp /etc/apt/sources.list.d/pmg-enterprise.list /etc/apt/sources.list.d/pmg-community.list && \
sed "s/^deb/#deb/g" -i /etc/apt/sources.list.d/pmg-enterprise.list && \
sed -e "s/pve-enterprise/pve-no-subscription/g" \
    -e "s/enterprise./download./g" \
    -e "s/https:/http:/g" -i /etc/apt/sources.list.d/pmg-community.list

[[ -z $(grep contrib /etc/apt/sources.list) ]] && \
sed -e "s/ main/ main contrib/" \
    -e "s/^deb-src/#deb-src/g" -i /etc/apt/sources.list

apt-get update > /dev/null
/usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install byobu debian-archive-keyring debian-goodies etckeeper fail2ban ipset pigz
/usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' dist-upgrade
pmgupdate

/usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoremove
/usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' autoclean

systemctl disable rpcbind
systemctl stop rpcbind

timedatectl set-timezone UTC
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

cat  <<EOF > /bin/pigzwrapper
#!/bin/sh
PATH=/bin:\$PATH
GZIP="-1"
exec /usr/bin/pigz "\$@"
EOF
mv -f /bin/gzip /bin/gzip.original
cp -f /bin/pigzwrapper /bin/gzip
chmod +x /bin/pigzwrapper
chmod +x /bin/gzip

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
# 1 hour
bantime = 3600
EOF
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
banaction = iptables-ipset-proto4
EOF
systemctl enable fail2ban

echo -e "
vm.swappiness=10
vm.min_free_kbytes=524288
fs.inotify.max_user_watches=1048576" >> /etc/sysctl.conf
echo 1048576 > /proc/sys/fs/inotify/max_user_watches
sysctl -p

cat <<EOF >> /etc/security/limits.conf
* soft     nproc          256000
* hard     nproc          256000
* soft     nofile         256000
* hard     nofile         256000
root soft     nproc          256000
root hard     nproc          256000
root soft     nofile         256000
root hard     nofile         256000
EOF

cat <<EOF > /etc/sysctl.d/10-kernel-bbr.conf
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

cat <<EOF > /etc/sysctl.d/60-maxkeys.conf
# Increase kernel max Key limit
kernel.keys.root_maxkeys=1000000
kernel.keys.maxkeys=1000000
EOF

echo "DefaultLimitNOFILE=256000" >> /etc/systemd/system.conf
echo "DefaultLimitNOFILE=256000" >> /etc/systemd/user.conf
echo 'session required pam_limits.so' | tee -a /etc/pam.d/common-session-noninteractive
echo 'session required pam_limits.so' | tee -a /etc/pam.d/common-session
echo 'session required pam_limits.so' | tee -a /etc/pam.d/runuser-l

cd ~ && echo "ulimit -n 256000" >> .bashrc ; echo "ulimit -n 256000" >> .profile
