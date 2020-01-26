# mount disk from host to KVM guest
[ref](https://pve.proxmox.com/wiki/Physical_disk_to_kvm)
````
qm set  592  -scsi2 /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC
update VM 592: -scsi2 /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC
````
