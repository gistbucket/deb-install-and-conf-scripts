# container build with: linuxserver/qbittorrent
## since this container will have to create a tunnel device it have to run in privileged mode

### based on https://support.purevpn.com/linux-openvpn-command
### run as usual your linuxserver/qbittorrent container

CONTAINER=
HOME=/config
PUREVPN-USERNAME=""
PUREVPN-PASSWORD=""
COUNTRY=""

docker exec -ti {CONTAINER:-qbittorrent} apt update
docker exec -ti {CONTAINER:-qbittorrent} apt install -y openvpn
docker exec -ti {CONTAINER:-qbittorrent} wget https://s3-us-west-1.amazonaws.com/heartbleed/windows/New+OVPN+Files.zip
docker exec -ti {CONTAINER:-qbittorrent} unzip -ojd $HOME/.purevpn New+OVPN+Files.zip
docker exec -ti {CONTAINER:-qbittorrent} rm New+OVPN+Files.zip
docker exec -ti {CONTAINER:-qbittorrent} rm -Rf $HOME/.purevpn/*udp*
docker exec -ti {CONTAINER:-qbittorrent} sed -i "s/auth-user-pass.*/auth-user-pass $HOME\/.purevpn-login.conf/" *.ovpn
docker exec -ti {CONTAINER:-qbittorrent} sed -i '/^route-.*/d' *.ovpn
docker exec -ti {CONTAINER:-qbittorrent} sed -i 's/^route.*/route-nopull/' *.ovpn

## PUT YOUR USERNAME PASSWORD IN /config/.purevpn-login.conf
docker exec -ti {CONTAINER:-qbittorrent} echo $PUREVPN-USERNAME > $HOME/.purevpn-login.conf
docker exec -ti {CONTAINER:-qbittorrent} echo $PUREVPN-PASSWORD >> $HOME/.purevpn-login.conf
docker exec -ti {CONTAINER:-qbittorrent} chmod 0400 $HOME/.purevpn-login.conf

## ESTABLISH CONNECTION FROM THE HOST
docker exec -ti ${CONTAINER:-qbittorrent} openvpn /config/.purevpn/${COUNTRY:-nl}2-ovpn-tcp-tcp.ovpn &
