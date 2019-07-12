# ref: https://wiki.debian.org/BitTorrent/Transmission#Server_installation

[[ -z $(grep -qa container=lxc /proc/1/environ) ]] && \
wget -P /tmp https://raw.githubusercontent.com/JDmnT/Debian/master/lxc-client-init.sh
bash /tmp/lxc-client-init.sh

apt install -y transmission-daemon
service transmission-daemon stop

sed 's|http://www.example.com/blocklist|http://john.bitsurge.net/public/biglist.p2p.gz|' -i /etc/transmission-daemon/settings.json
sed 's|blocklist-enabled": false|blocklist-enabled": true|' -i /etc/transmission-daemon/settings.json
sed 's|umask": 18|umask": 7|' -i /etc/transmission-daemon/settings.json

service transmission-daemon start
