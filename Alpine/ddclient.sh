#ref: https://wiki.alpinelinux.org/wiki/Ddclient

curl -fsSLo /tmp/base.sh https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/base.sh
sh /tmp/base.sh

apk add --no-cache \
  make \
  perl perl-io-socket-ssl perl-log-log4perl perl-net-ip perl-netaddr-ip perl-test-taint perl-utils perl-yaml 

yes|cpan Data::Validate::IP JSON::Any

wget -O /tmp/ddclient.zip https://sourceforge.net/projects/ddclient/files/latest/download
unzip /tmp/ddclient.zip 
cp /tmp/ddclient-*/ddclient /usr/bin/

mkdir /etc/ddclient /var/cache/ddclient

curl -fsSLo /etc/ddclient/ddclient.conf https://raw.githubusercontent.com/jodumont/ConFig/master/etc/ddclient/ddclient.conf
curl -fsSLo /etc/init.d/ddclient https://wiki.alpinelinux.org/images/b/bc/Ddclient-install.sh

chomod 600 /etc/ddclient/ddclient.conf
chmod +x /etc/init.d/ddclient
rc-update add ddclient
