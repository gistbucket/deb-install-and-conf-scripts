modprobe -r usb-storage
echo -e "## lynis recommandation STRG-1840
blacklist usb-storage
install usb-storage /bin/true
" > /etc/modprobe.d/blacklist_usb
