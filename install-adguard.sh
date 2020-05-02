SCRIPT=1strun-lxc-ct.sh

wget -qO /tmp/$SCRIPT https://raw.githubusercontent.com/JOduMonT/DEB/master/$SCRIPT
bash /tmp/$SCRIPT

wget -qO /tmp/AdGuardHome_linux_amd64.tar.gz https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
tar -zxvf /tmp/AdGuardHome_linux_amd64.tar.gz -C /opt
/opt/AdGuardHome/AdGuardHome -s install
