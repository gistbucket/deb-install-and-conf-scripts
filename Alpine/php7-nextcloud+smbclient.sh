ref: https://docs.nextcloud.com/server/15/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
ref: https://github.com/nextcloud/docker/blob/a1ed54243dbcf7e9b7ebdb77fc325a9d8ebdb3a5/15.0/fpm-alpine/Dockerfile

curl -fsSLo /tmp/nextcloud.sh https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/php7-nextcloud.sh
sh /tmp/nextcloud.sh

apk add --no-cache --upgrade \
  autoconf automake \
	file \
	g++ gcc \
	make \
	php7-dev \
	re2c \
	samba-client samba-dev \
  zlib-dev
  
git clone git://github.com/eduardok/libsmbclient-php.git /tmp/smbclient
cd /tmp/smbclient
phpize7 ./configure --with-php-config=/usr/bin/php-config7
make
make install
echo "extension="smbclient.so"" > /etc/php7/conf.d/smbclient
