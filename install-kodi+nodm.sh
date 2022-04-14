# this script will install kodi and nodm so at the next boot kodi will launch automatically as kodi user
# usage case: on top proxmox, openmediavault, raspbian, or any minimal debian installation

export DEBIAN_FRONTEND=noninteractive

apt install -yq alsa-utils kodi libasound pulseaudio pulseaudio-bluetooth nodm xinit

useradd -mU kodi

echo "exec /usr/bin/kodi-standalone" > /home/kodi/.xinitrc
chown kodi:kodi /home/kodi/.xinitrc
chmod +rx /home/kodi/.xinitrc

sed -e "s|^NODM_USER=.*|NODM_USER=kodi|" \
    -e "s|^NODM_XSESSION=.*|NODM_XSESSION=/home/kodi/.xinitrc|" \
    -i /etc/default/nodm
