#ref: https://wiki.alpinelinux.org/wiki/Ddclient

apk add --no-cache \
  curl \
  make \
  perl perl-digest-sha1 perl-json perl-utils perl-test-taint perl-netaddr-ip perl-net-ip perl-yaml perl-log-log4perl perl-io-socket-inet6 perl-io-socket-ssl \
  unzip \
  wget

yes|cpan Data::Validate::IP JSON::Any

wget https://sourceforge.net/projects/ddclient/files/latest/download -O ddclient.zip
unzip ddclient.zip 
cp ddclient-*/ddclient /usr/bin/

mkdir /etc/ddclient /var/cache/ddclient

curl -fsSLo /etc/ddclient/ddclient.conf https://raw.githubusercontent.com/jodumont/ConFig/master/etc/ddclient/ddclient.conf
curl -fsSLo /etc/init.d/ddclient https://wiki.alpinelinux.org/images/b/bc/Ddclient-install.sh

chmod +x /etc/init.d/ddclient
rc-update add ddclient
