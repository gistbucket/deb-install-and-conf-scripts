# container build with: linuxserver/qbittorrent
## since this container will have to create a tunnel device it have to run in privileged mode

### based on https://support.purevpn.com/linux-openvpn-command
### run as usual your linuxserver/qbittorrent container

apt update
apt install -y openvpn
wget https://s3-us-west-1.amazonaws.com/heartbleed/windows/New+OVPN+Files.zip
unzip -od $HOME/.purevpn New+OVPN+Files.zip
rm New+OVPN+Files.zip
cd $HOME/.purevpn
rm -Rf *udp*
sed -i 's/auth-user-pass.*/auth-user-pass ..\/.purevpn-login.conf/' *.ovpn
sed -i '/^route-.*/d' *.ovpn
sed -i 's/^route.*/route-nopull/' *.ovpn

## PUT YOUR USERNAME PASSWORD IN $HOME/.purevpn-login.conf
echo $PURVPN-USERNAME > $HOME/.purevpn-login.conf
echo $PURVPN-PASSWORD >> $HOME/.purevpn-login.conf
chmod 0400 $HOME/.purevpn-login.conf

## ESTABLISH CONNECTION
openvpn sg2-ovpn-tcp-tcp.ovpn
