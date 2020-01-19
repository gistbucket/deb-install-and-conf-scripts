# container build with: linuxserver/qbittorrent
## since this container will have to create a tunnel device it have to run in privileged mode

### based on https://support.purevpn.com/linux-openvpn-command
### run as usual your linuxserver/qbittorrent container

CONTAINER=
PUREVPN-USERNAME=""
PUREVPN-PASSWORD=""
COUNTRY=""

docker exec -t ${CONTAINER:-qbittorrent} apt update
docker exec -t ${CONTAINER:-qbittorrent} apt install -y openvpn wget
docker exec -t ${CONTAINER:-qbittorrent} wget https://s3-us-west-1.amazonaws.com/heartbleed/windows/New+OVPN+Files.zip
docker exec -t ${CONTAINER:-qbittorrent} unzip -ojd /config/.purevpn New+OVPN+Files.zip
docker exec -t ${CONTAINER:-qbittorrent} rm New+OVPN+Files.zip
docker exec -t ${CONTAINER:-qbittorrent} rm -Rf /config/.purevpn/*udp*
docker exec -t ${CONTAINER:-qbittorrent} sed -i "s/auth-user-pass.*/auth-user-pass \/config\/.purevpn-login.conf/" /config/.purevpn/*.ovpn
docker exec -t ${CONTAINER:-qbittorrent} sed -i '/^route-.*/d' /config/.purevpn/*.ovpn
docker exec -t ${CONTAINER:-qbittorrent} sed -i 's/^route.*/route-nopull/' /config/.purevpn/*.ovpn

## PUT YOUR USERNAME PASSWORD IN /config/.purevpn-login.conf
docker exec -t {CONTAINER:-qbittorrent} echo $PUREVPN-USERNAME > $HOME/.purevpn-login.conf
docker exec -t {CONTAINER:-qbittorrent} echo $PUREVPN-PASSWORD >> $HOME/.purevpn-login.conf
docker exec -t {CONTAINER:-qbittorrent} chmod 0400 $HOME/.purevpn-login.conf

## ESTABLISH CONNECTION FROM THE HOST
docker exec -ti ${CONTAINER:-qbittorrent} openvpn /config/.purevpn/${COUNTRY:-nl}2-ovpn-tcp-tcp.ovpn &
