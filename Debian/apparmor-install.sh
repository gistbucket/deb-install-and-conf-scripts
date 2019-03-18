#!/bin/bash

apt update
apt install -y apparmor apparmor-profiles apparmor-utils

if [ "$seconds" -eq 0 ];then
  sed 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5"/g' /etc/default/grub
  update-grub

elif[ "$seconds" -gt 0 ];then
  sed 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5"/g' /etc/default/grub
  update-grub

else
   echo "Sorry you must edit manually '/etc/default/grub' and add 'apparmor=1 security=apparmor cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5' at the end of GRUB_CMDLINE_LINUX_DEFAULT= line"
fi
