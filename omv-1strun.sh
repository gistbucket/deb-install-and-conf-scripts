#!/bin/bash -eux

rm /var/cache/apt/archives/lock

apt remove -y --purge amd64-microcode \
  firmware-amd-graphics firmware-atheros \
  firmware-bnx2 firmware-bnx2x firmware-brcm80211 \
  firmware-cavium \
  firmware-intelwimax firmware-ipw2x00 firmware-ivtv firmware-iwlwifi \
  firmware-libertas \
  firmware-myricom \
  firmware-netxen \
  firmware-qlogic \
  firmware-realtek \
  firmware-samsung firmware-siano \
  firmware-ti-connectivity \
  netcat

## install apparmor et cie
apt install -y apparmor apparmor-profiles apparmor-utils \
  bridge-utils \
  byobu \
  etckeeper \
  git \
  libvirt-daemon libvirt-daemon-system \
  netcat-openbsd \
  qemu-kvm qemu-utils qemu-system-arm qemu-system-x86

apt upgrade -y

## fix the weakref.py error
wget -O /usr/lib/python3.5/weakref.py https://raw.githubusercontent.com/python/cpython/9cd7e17640a49635d1c1f8c2989578a8fc2c1de6/Lib/weakref.py

## install extras
wget -O - http://omv-extras.org/install | bash

apt update
apt upgrade -y

[[ -z cat /proc/cpuinfo|grep endor|grep ntel ]] && \
  sed 's|^\(GRUB_CMDLINE_LINUX_DEFAULT="quiet\)"$|\1 intel_iommu=on apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5"|' -i /etc/default/grub

update-grub

reboot
