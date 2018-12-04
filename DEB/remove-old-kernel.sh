apt remove --purge *$(ls /lib/modules/|grep -v $(uname -a|cut -d' ' -f3))*
