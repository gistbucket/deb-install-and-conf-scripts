apt remove --purge netcat
apt -y install qemu-kvm bridge-utils libvirt-daemon libvirt-daemon-system netcat-openbsd

cat >> /etc/sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF
sysctl -p /etc/sysctl.conf
 
echo "RECOMMENDED: adding a user in libvirt group with usermod -aG libvirt $USER"
