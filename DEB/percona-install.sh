curl -fsSLo /tmp/percona.deb https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i /tmp/percona.deb
apt update
lastPercona=$(apt search percona-server-server-|grep "percona-server-server-"|cut -d'/' -f1|tail -1|rev|cut -d- -f1|rev)
apt install -y percona-server-server-$lastPercona percona-server-client-$lastPercona
