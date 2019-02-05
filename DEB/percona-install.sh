curl -fsSLo /tmp/percona.deb https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i /tmp/percona.deb
apt update
lastPercona=$(apt search percona-server-server-|grep "percona-server-server-"|cut -d'/' -f1|tail -1|rev|cut -d- -f1|rev)
apt install -y percona-server-server-$lastPercona percona-server-client-$lastPercona

openssl genrsa -out /var/lib/mysql/private_key.pem 2048
openssl rsa -in /var/lib/mysql/private_key.pem -pubout -out /var/lib/mysql/public_key.pem
chmod 0400 /var/lib/mysql/private_key.pem
chmod 0444 /var/lib/mysql/public_key.pem
chown mysql:mysql /var/lib/mysql/*.pem
