## The easiest and fastest way to do it is

1. Create your container with `unprivileged = no` **but don't start it**
2. Backup it with exclusion (*change the 100 for your VMID*)  
`vzdump 100 --exclude-path /var/spool/postfix/dev/random --exclude-path /var/spool/postfix/dev/urandom`
3. Restore this backup with unprivileged = yes

ref: https://forum.proxmox.com/threads/unprivileged-containers.26148/page-2#post-248550
