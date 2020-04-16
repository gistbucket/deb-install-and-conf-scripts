#!/usr/bin/env bash -eux

# This script is use on Ubuntu 18.04LTS at Linode, Vultr and UpCloud, but it probably works at any providers.

## Set TimeZone
timedatectl set-timezone $(curl -s worldtimeapi.org/api/ip/$(curl -s ifconfig.me/ip)|cut -d\" -f16)
apt list --installed > $HOME/packages.installed
apt update


## Remove useless packages/services
apt purge -y btrfs* crypsetup* dmsetup lxc* lxd* snap* mdadm* open-iscsi* ubuntu-cloudimage* wireless* xfs*

## Install tools + latest kernel
apt install -y etckeeper fail2ban linux-generic-hwe-18.04

## Install OpenLiteSpeed + WordPress
bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/wpimgsetup.sh )

### Regenerate password for Web Admin, Database, setup Welcome Message
bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Cloud-init/per-instance.sh )

## Reboot server
reboot
