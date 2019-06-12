export LANG="en_US.UTF-8"
export LC_ALL="C"

echo -e "Acquire::ForceIPv4 \"true\";\\n" > /etc/apt/apt.conf.d/99force-ipv4

[[ -z $(grep contrib /etc/apt/sources.list) ]] && \
sed -e "s/ main/ main contrib/" \
    -e "s/^deb-src/#deb-src/g" -i /etc/apt/sources.list

[[ ! -f /etc/apt/sources.list.d/pmg-community.list ]] && \
echo "deb http://download.proxmox.com/debian/pmg stretch pmg-no-subscription" > /etc/apt/sources.list.d/pmg-community.list && \
wget http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg

apt update
apt install -y byobu debian-archive-keyring debian-goodies etckeeper fail2ban ipset pigz

apt install -y proxmox-mailgateway
