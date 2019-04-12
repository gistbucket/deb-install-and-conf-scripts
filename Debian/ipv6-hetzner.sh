curl -fsSLo /etc/resolv.conf https://raw.githubusercontent.com/jodumont/ConFig/master/etc/resolv.conf
chattr +i /etc/resolv.conf

echo -e "
auto lo ens3
iface lo inet loopback

iface ens3 inet dhcp
#iface ens3 inet static
#  address /32
#  gateway 172.31.1.1
#  pointopoint 172.31.1.1

#iface ens3 inet6 static
#  address /64
#  gateway fe80::1" >> /etc/network/interface

nano /etc/network/interface
