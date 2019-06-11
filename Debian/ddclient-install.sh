apt install -y git libdata-validate-ip-perl libjson-any-perl libio-socket-ssl-perl

cd /tmp
git clone https://github.com/ddclient/ddclient.git
cd /tmp/ddclient
cp ddclient /usr/sbin/
mkdir /etc/ddclient /var/cache/ddclient
cp sample-etc_ddclient.conf /etc/ddclient/ddclient.conf

# EDIT CONFIG -> /etc/ddclient/ddclient.conf

cp sample-etc_rc.d_init.d_ddclient.ubuntu /etc/init.d/ddclient
systemctl enable ddclient
systemctl start ddclient
