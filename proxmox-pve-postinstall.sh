#!/usr/bin/env bash -eux

PVEKernel="5.15"

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
apt purge -y ntp openntpd chrony
apt install -y byobu curl debian-archive-keyring debian-goodies etckeeper fail2ban haveged ksm-control-daemon ipset nano pigz pve-kernel-$PVEKernel unzip wget whois zfsutils zip
apt dist-upgrade -y
pveam update

## Ensure ksmtuned (ksm-control-daemon) is enabled and optimise according to ram size
if [[ RAM_SIZE_GB -le 16 ]] ; then
    # start at 50% full
    KSM_THRES_COEF=50
    KSM_SLEEP_MSEC=80
elif [[ RAM_SIZE_GB -le 32 ]] ; then
    # start at 60% full
    KSM_THRES_COEF=40
    KSM_SLEEP_MSEC=60
elif [[ RAM_SIZE_GB -le 64 ]] ; then
    # start at 70% full
    KSM_THRES_COEF=30
    KSM_SLEEP_MSEC=40
elif [[ RAM_SIZE_GB -le 128 ]] ; then
    # start at 80% full
    KSM_THRES_COEF=20
    KSM_SLEEP_MSEC=20
else
    # start at 90% full
    KSM_THRES_COEF=10
    KSM_SLEEP_MSEC=10
fi
sed -i -e "s/\# KSM_THRES_COEF=.*/KSM_THRES_COEF=${KSM_THRES_COEF}/g" /etc/ksmtuned.conf
sed -i -e "s/\# KSM_SLEEP_MSEC=.*/KSM_SLEEP_MSEC=${KSM_SLEEP_MSEC}/g" /etc/ksmtuned.conf
    
systemctl enable ksmtuned

[[ "$(grep -i -m 1 "model name" /proc/cpuinfo | grep -i "EPYC")" != "" ]] || [[ "$(grep -i -m 1 "model name" /proc/cpuinfo | grep -i "Ryzen")" != "" ]] && \
  echo "options kvm ignore_msrs=Y" >> /etc/modprobe.d/kvm.conf && \
  echo "options kvm report_ignored_msrs=N" >> /etc/modprobe.d/kvm.conf

apt autoremove -y
apt autoclean -y

systemctl disable rpcbind
systemctl stop rpcbind

## Set Timezone, empty = set automatically by ip
this_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
timezone="$(curl "https://ipapi.co/${this_ip}/timezone")"
timedatectl set-timezone "$timezone"

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

/////
## Increase max user watches
# BUG FIX : No space left on device
cat <<EOF > /etc/sysctl.d/99-maxwatches.conf
# Increase max user watches
fs.inotify.max_user_watches=1048576
fs.inotify.max_user_instances=1048576
fs.inotify.max_queued_events=1048576
EOF

## Increase max FD limit / ulimit
cat <<EOF >> /etc/security/limits.d/99-limits.conf
# Increase max FD limit / ulimit
* soft     nproc          256000
* hard     nproc          256000
* soft     nofile         256000
* hard     nofile         256000
root soft     nproc          256000
root hard     nproc          256000
root soft     nofile         256000
root hard     nofile         256000
EOF

## Increase kernel max Key limit
cat <<EOF > /etc/sysctl.d/99-maxkeys.conf
# Increase kernel max Key limit
kernel.keys.root_maxkeys=1000000
kernel.keys.maxkeys=1000000
EOF

## Set systemd ulimits
echo "DefaultLimitNOFILE=256000" >> /etc/systemd/system.conf
echo "DefaultLimitNOFILE=256000" >> /etc/systemd/user.conf

echo 'session required pam_limits.so' >> /etc/pam.d/common-session
echo 'session required pam_limits.so' >> /etc/pam.d/runuser-l

## Set ulimit for the shell user
echo "ulimit -n 256000" >> /root/.profile

## Optimise logrotate
cat <<EOF > /etc/logrotate.conf
daily
su root adm
rotate 7
create
compress
size=10M
delaycompress
copytruncate

include /etc/logrotate.d
EOF
systemctl restart logrotate


## Limit the size and optimise journald
cat <<EOF > /etc/systemd/journald.conf
[Journal]
# Store on disk
Storage=persistent
# Don't split Journald logs by user
SplitMode=none
# Disable rate limits
RateLimitInterval=0
RateLimitIntervalSec=0
RateLimitBurst=0
# Disable Journald forwarding to syslog
ForwardToSyslog=no
# Journald forwarding to wall /var/log/kern.log
ForwardToWall=yes
# Disable signing of the logs, save cpu resources.
Seal=no
Compress=yes
# Fix the log size
SystemMaxUse=64M
RuntimeMaxUse=60M
# Optimise the logging and speed up tasks
MaxLevelStore=warning
MaxLevelSyslog=warning
MaxLevelKMsg=warning
MaxLevelConsole=notice
MaxLevelWall=crit
EOF
systemctl restart systemd-journald.service
journalctl --vacuum-size=64M --vacuum-time=1d;
journalctl --rotate

## Net optimising
cat <<EOF > /etc/default/haveged
#   -w sets low entropy watermark (in bits)
DAEMON_ARGS="-w 1024"
EOF
systemctl daemon-reload
systemctl enable haveged

## Increase vzdump backup speed
sed -i "s/#bwlimit:.*/bwlimit: 0/" /etc/vzdump.conf
sed -i "s/#ionice:.*/ionice: 5/" /etc/vzdump.conf

## Optimise Memory
cat <<EOF > /etc/sysctl.d/99-memory.conf
# Memory Optimising
## Bugfix: reserve 512MB memory for system
vm.min_free_kbytes=524288
vm.nr_hugepages=72
# (Redis/MongoDB)
vm.max_map_count=262144
vm.overcommit_memory = 1
EOF

## Enable TCP BBR congestion control
cat <<EOF > /etc/sysctl.d/99-kernel-bbr.conf
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

## Enable TCP fastopen
cat <<EOF > /etc/sysctl.d/99-tcp-fastopen.conf
# TCP fastopen
net.ipv4.tcp_fastopen=3
EOF

## Enable Network optimising
cat <<EOF > /etc/sysctl.d/99-net.conf
net.core.netdev_max_backlog=8192
net.core.optmem_max=8192
net.core.rmem_max=16777216
net.core.somaxconn=8151
net.core.wmem_max=16777216
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_base_mss = 1024
net.ipv4.tcp_challenge_ack_limit = 999999999
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_time=240
net.ipv4.tcp_limit_output_bytes=65536
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_rmem=8192 87380 16777216
net.ipv4.tcp_sack=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_wmem=8192 65536 16777216
net.netfilter.nf_conntrack_generic_timeout = 60
net.netfilter.nf_conntrack_helper=0
net.netfilter.nf_conntrack_max = 524288
net.netfilter.nf_conntrack_tcp_timeout_established = 28800
net.unix.max_dgram_qlen = 4096
EOF

## Bugfix: high swap usage with low memory usage
cat <<EOF > /etc/sysctl.d/99-swap.conf
# Bugfix: high swap usage with low memory usage
vm.swappiness=10
EOF

## Increase Max FS open files
cat <<EOF > /etc/sysctl.d/99-fs.conf
# Max FS Optimising
fs.nr_open=12000000
fs.file-max=9000000
EOF

## Customise bashrc
cat <<EOF >> /root/.bashrc
export HISTTIMEFORMAT="%d/%m/%y %T "
export PS1='\u@\h:\W \$ '
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
source /etc/profile.d/bash_completion.sh
export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
EOF
echo "source /root/.bashrc" >> /root/.bash_profile

## Optimise ZFS arc size accoring to memory size
if [ "$(command -v zfs)" != "" ] ; then
  if [[ RAM_SIZE_GB -le 16 ]] ; then
    MY_ZFS_ARC_MIN=536870911
    MY_ZFS_ARC_MAX=536870912
  elif [[ RAM_SIZE_GB -le 32 ]] ; then
    # 1GB/1GB
    MY_ZFS_ARC_MIN=1073741823
    MY_ZFS_ARC_MAX=1073741824
  else
    MY_ZFS_ARC_MIN=$((RAM_SIZE_GB * 1073741824 / 16))
    MY_ZFS_ARC_MAX=$((RAM_SIZE_GB * 1073741824 / 8))
  fi

# Enforce the minimum, incase of a faulty vmstat
  if [[ MY_ZFS_ARC_MIN -lt 536870911 ]] ; then
    MY_ZFS_ARC_MIN=536870911
  fi
  if [[ MY_ZFS_ARC_MAX -lt 536870912 ]] ; then
    MY_ZFS_ARC_MAX=536870912
  fi
fi

cat <<EOF > /etc/modprobe.d/99-zfsarc.conf
# Use 1/16 RAM for MAX cache, 1/8 RAM for MIN cache, or 1GB
options zfs zfs_arc_min=$MY_ZFS_ARC_MIN
options zfs zfs_arc_max=$MY_ZFS_ARC_MAX

# use the prefetch method
options zfs l2arc_noprefetch=0

# max write speed to l2arc
# tradeoff between write/read and durability of ssd (?)
# default : 8 * 1024 * 1024
# setting here : 500 * 1024 * 1024
options zfs l2arc_write_max=524288000
options zfs zfs_txg_timeout=60
EOF

/////
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

# Lynis security scan tool by Cisofy
wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | apt-key add -
echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" > /etc/apt/sources.list.d/cisofy-lynis.list
apt update > /dev/null 2>&1
apt -y install lynis

[[ "$(whois -h v4.whois.cymru.com " -t $(curl ipinfo.io/ip 2> /dev/null)" | tail -n 1 | cut -d'|' -f3 | grep -i "ovh")" != "" ]] && \
  wget ftp://ftp.ovh.net/made-in-ovh/rtm/install_rtm.sh -c -O install_rtm.sh && bash install_rtm.sh && rm install_rtm.sh

## Protect the web interface with fail2ban
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
findtime = 600
EOF
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
banaction = iptables-ipset-proto4
EOF
systemctl enable fail2ban

apt purge -y btrfs-progs memtest86+
rm -Rf /usr/share/initramfs-tools/hooks/{btrfs,dmsetup,iscsi,lvm2,xfs,thin-provisioning-tools} scripts/local-{block/lvm2,bottom/iscsi,premount/{btrfs,resume},top/{iscsi,lvm2}}
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
