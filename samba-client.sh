SERVER=
SHARE=
USER=

sudo mkdir /mnt/$SHARE
sudo mount -t cifs -o user=$USER //$SERVER/$SHARE /mnt/$SHARE
