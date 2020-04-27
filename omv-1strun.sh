#!/bin/bash -eux

KVM="" # expect yes

## fix the weakref.py error
wget -O /usr/lib/python3.5/weakref.py https://raw.githubusercontent.com/python/cpython/9cd7e17640a49635d1c1f8c2989578a8fc2c1de6/Lib/weakref.py

## install extras
wget -O - http://omv-extras.org/install | bash

## remove firmware
rm /var/cache/apt/archives/lock
apt purge amd64-microcode \
  firmware-amd-graphics firmware-atheros \
  firmware-bnx2 firmware-bnx2x firmware-brcm80211 \
  firmware-cavium \
  firmware-intel-sound firmware-intelwimax firmware-ipw2x00 firmware-ivtv firmware-iwlwifi \
  firmware-libertas \
  firmware-myricom \
  firmware-netronome firmware-netxen \
  firmware-qlogic \
  firmware-realtek \
  firmware-samsung firmware-siano \
  firmware-ti-connectivity \
  firmware-qcom-media \
  netcat

## install apparmor et cie
apt install -y apparmor apparmor-profiles apparmor-utils \
  byobu \
  etckeeper \
  git \
  libvirt-daemon libvirt-daemon-system \
  openmediavault-backup openmediavault-clamav openmediavault-diskstats openmediavault-fail2ban openmediavault-locate openmediavault-luksencryption openmediavault-nut openmediavault-resetperms openmediavault-usbbackup

## install KVM
[[ $KVM == 'yes' ]] && \
apt install -y bridge-utils \
  netcat-openbsd \
  qemu-kvm qemu-utils qemu-system-arm qemu-system-x86

apt upgrade -y

[[ -z cat /proc/cpuinfo|grep endor|grep ntel ]] && \
  sed 's|^\(GRUB_CMDLINE_LINUX_DEFAULT="\)"$|\1 intel_iommu=on apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5 loglevel=5"|' -i /etc/default/grub

update-grub

reboot
