### DONE
## High Availability
## CRM for Cluster
## LRM for Local
systemctl disable pve-ha-crm pve-ha-lrm spiceproxy

### corosync
## corosync only starts if there is a /etc/corosync/corosync.conf config, it has a ConditionPathExists=/etc/corosync/corosync.conf in it's unit file, so not point to mask/disable that one if no cluster is configured anyway.
# systemctl disble corosync

### FIREWALL
# systemctl disable pve-firewall pvefw-logger

### ???
# systemctl stop pveproxy pvedaemon pvebanner
# systemctl stop pve-daily-update pvestatd
