#KVM

## mount disk from host to KVM guest
[ref](https://pve.proxmox.com/wiki/Physical_disk_to_kvm)

### Identify the ID of your disks
````bash
ls -lha /dev/disk/by-id/|grep sd[c,d]
````
### Add them to your VM as virtio device
````bash
qm set 100 -virtio1 /dev/disk/by-id/ata-WDC_WD30EFRX-68E*
qm set 100 -virtio2 /dev/disk/by-id/ata-WDC_WD30EFRX-68N*
````
