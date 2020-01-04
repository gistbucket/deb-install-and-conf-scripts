# How to configure a bridge with netplan for KVM / QEMU

## Works with ubuntu 18.04 LTS

### edit /etc/netplan/network.yaml 

> nano /etc/netplan/network.yaml 

```
network:
  version: 2
  renderer: networkd

  ethernets:
    enp0s31f6:
      dhcp4: no
      dhcp6: no

  bridges:
    br0:
      interfaces: [enp0s31f6]
      addresses: [192.168.1.11/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1]
      dhcp4: no
      dhcp6: no
```

### edit /etc/libvirt/qemu/networks/br0.xml

> virsh net-edit br0

```
<network>
  <name>br0</name>
  <forward mode='bridge'/>
  <bridge name='br0'/>
</network>
```

### be sure to configure NF (netfilter)

```
cat >> /etc/sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF
sysctl -p /etc/sysctl.conf
```
