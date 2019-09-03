if [ ! $(grep tmp /etc/fstab) ]; then
rm -Rf /{tmp,var/tmp}/{.*,*}
echo -e "
tmpfs /dev/shm tmpfs nodev,nosuid,noexec 0 0
tmpfs /tmp tmpfs nodev,nosuid,size=512M 0 0
/tmp /var/tmp none bind 0 0
" >> /etc/fstab
fi
