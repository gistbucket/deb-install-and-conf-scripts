modprobe -r firewire-core firewire_ohci
echo -e "## lynis recommandation STRG-1846
blacklist firewire-core
install firewire_core /bin/true
install firewire_ohci /bin/true
" > /etc/modprobe.d/blacklist_firewire
