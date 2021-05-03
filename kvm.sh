apt remove --purge netcat
apt -y install qemu-kvm bridge-utils libvirt-daemon libvirt-daemon-system netcat-openbsd qemu-utils

echo -e '
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0' | tee -a /etc/sysctl.conf 
sysctl -p /etc/sysctl.conf
 
echo "RECOMMENDED: adding a user in libvirt group with usermod -aG libvirt $USER"

sudo nmcli con add ifname br0 type bridge con-name br0
sudo nmcli con add type bridge-slave ifname enp0s31f6 master br0
sudo nmcli con modify br0 bridge.stp no
