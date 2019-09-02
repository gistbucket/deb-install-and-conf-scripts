apt remove --purge netcat
apt -y install qemu-kvm bridge-utils libvirt-daemon libvirt-daemon-system netcat-openbsd

echo "RECOMMENDED: adding a user in libvirt group with usermod -aG libvirt $USER"
