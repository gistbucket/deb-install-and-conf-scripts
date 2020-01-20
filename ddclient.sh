[ "$(grep LC_ALL /etc/bash.bashrc)" ] || echo -e '
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL="C"
' >> /etc/bash.bashrc

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C
locale-gen en_US.UTF-8

apt install -y libdata-validate-ip-perl libio-socket-ssl-perl wget

wget https://raw.githubusercontent.com/ddclient/ddclient/master/ddclient -O /usr/sbin/ddclient
chmod +x /usr/sbin/ddclient

mkdir /{etc,var/cache}/ddclient

wget https://raw.githubusercontent.com/ddclient/ddclient/master/sample-etc_systemd.service -O /lib/systemd/system/ddclient.service
systemctl enable ddclient

wget https://raw.githubusercontent.com/ddclient/ddclient/master/sample-etc_ddclient.conf -O /etc/ddclient/ddclient.conf
sed -i "s/^#use=web, web=checkip.dyndns.org\/, web-skip='IP Address' # found after IP Address/use=web, web=checkip.dyndns.org\/, web-skip='IP Address' # found after IP Address/" /etc/ddclient/ddclient.conf

echo "adjust your configuration in : /etc/ddclient/ddclient.conf"
