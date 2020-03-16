#!/bin/bash -eu

echo -e "[user]
        name = $(hostname -s)
        email = hostmaster@$(hostname -d)" > /root/.gitconfig
apt install -y etckeeper

PASSWORD=$(< /dev/urandom tr -dc @.,/=_A-Z-a-z-0-9 | head -c24)
REDISPWD=$(< /dev/urandom tr -dc @.,/=_A-Z-a-z-0-9 | head -c24)

export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C
locale-gen en_US.UTF-8

REMOVE="apport* autofs avahi* beep btrfs-* cryptsetup cryptsetup-bin dmsetup eatmydata lxcfs lxd lxd-client lvm2 mdadm ntfs-3g open-iscsi pastebinit popularity-contest postfix prelink rsh* rsync snapd talk* telnet* tftp* ubuntu-report ufw xfsprogs whoopsie xinetd yp-tools ypbind"
## REMOVE PACKAGES
for package in $REMOVE; do
  apt purge -y $package
done

## DISABLE NET
NETPROTOCOLS="dccp sctp rds tipc"
for disable in $NETPROTOCOLS; do
  if ! grep -q $disable /etc/modprobe.d/disablenet.conf 2> /dev/null; then
    echo "install $disable /bin/true" >> /etc/modprobe.d/disablenet.conf
  fi
done

## DISABLE MISC FILE SYSTEM
FILESYSTEMS="cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat"
for disable in $FILESYSTEMS; do
  if ! grep -q $disable /etc/modprobe.d/disablefs.conf 2> /dev/null; then
    echo "install $disable /bin/true" >> /etc/modprobe.d/disablefs.conf
  fi
done

## DISABLE MODULES
MODULES="bluetooth bnep btusb cpia2 firewire-core floppy n_hdlc net-pf-31 pcspkr soundcore thunderbolt usb-midi usb-storage uvcvideo v4l2_common"
for disable in $MODULES; do
  if ! grep -q $disable /etc/modprobe.d/disablemod.conf 2> /dev/null; then
    echo "install $disable /bin/true" >> /etc/modprobe.d/disablemod.conf
  fi
done

wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh \
-a no \
-f -y no \
-g yes \
-k no \
-v no \
-w yes -o yes \
-x no -z no \
-c no -t no \
-s $(hostname -s).$(hostname -d) \
-e hostmaster@$(hostname -d) \
-p $PASSWORD

apt install -y curl php7.2-gmp php-imagick php-smbclient php-redis redis-server wget

[[ -z $REDISPWD ]] && \
#REDISPWD=$(openssl rand -base64 24)
sed 's|^port.*|port 0|' -i /etc/redis/redis.conf
sed 's|^# unixsocket .*|unixsocket /var/run/redis/redis.sock|' -i /etc/redis/redis.conf
sed 's|^# unixsocketperm .*|unixsocketperm 770|' -i /etc/redis/redis.conf
#sed "s|^# requirepass .*|requirepass $REDISPWD|" -i /etc/redis/redis.conf

for hUSER in $(grep hestia /etc/group|cut -d: -f4|sed 's/,/ /g'); do
usermod -aG redis $hUSER; done
systemctl restart redis
