 # LXC
 
 ## mount dir from host to lxc guest
 [ref](https://forum.proxmox.com/threads/lxc-cannot-assign-a-block-device-to-container.23256/#post-118361)
 
 ````bash
 lxc.mount.entry = /data/nas data none bind,create=dir 0 0
 ````
