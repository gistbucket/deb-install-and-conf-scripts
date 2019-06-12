## BASED ON https://github.com/hetzneronline/installimage/blob/master/post-install/proxmox5
## MUST HAVE AN IP FIX in /etc/network/interface
## EDIT /etc/hosts ref: https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch#Install_a_standard_Debian_Stretch_.28amd64.29

export LANG="en_US.UTF-8"
export LC_ALL="C"

echo -e "Acquire::ForceIPv4 \"true\";\\n" > /etc/apt/apt.conf.d/99force-ipv4

#sed -e "s// pvelocalhost/" -i /etc/hosts

[[ -z $(grep contrib /etc/apt/sources.list) ]] && \
sed -e "s/ main/ main contrib/" \
    -e "s/^deb-src/#deb-src/g" -i /etc/apt/sources.list

[[ ! -f /etc/apt/sources.list.d/pmg-community.list ]] && \
echo "deb http://download.proxmox.com/debian/pmg stretch pmg-no-subscription" > /etc/apt/sources.list.d/pmg-community.list && \
wget http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg

apt update
apt install -y byobu debian-archive-keyring debian-goodies etckeeper fail2ban ipset pigz

cat <<EOF | debconf-set-selections
postfix postfix/mailname           string $(hostname -f)
postfix postfix/chattr             boolean false
postfix postfix/mailbox_limit      string 0
postfix postfix/mynetworks         string 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
postfix postfix/recipient_delim    string +
postfix postfix/rfc1035_violation  boolean false
EOF

/usr/bin/env DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::='--force-confdef' install proxmox-mailgateway
