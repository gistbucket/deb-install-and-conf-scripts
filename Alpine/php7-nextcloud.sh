#ref: https://wiki.alpinelinux.org/wiki/Nextcloud
#ref: https://github.com/nextcloud/docker/blob/a1ed54243dbcf7e9b7ebdb77fc325a9d8ebdb3a5/15.0/fpm-alpine/Dockerfile

curl -fsSLo /tmp/nginx.sh https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/nginx.sh
sh /tmp/nginx.sh

apk add --no-cache --upgrade \
	ffmpeg \
	imagemagick \
	libxml2 \
	php7-apcu \
	php7-bz2 \
	php7-ctype php7-curl \
	php7-dom \
	php7-exif \
	php7-fileinfo php7-ftp \
	php7-gd php7-gmp \
	php7-iconv php7-imagick php7-imap php7-intl \
	php7-json \
	php7-ldap \
	php7-mbstring php7-mcrypt php7-memcached \
	php7-opcache php7-openssl \
	php7-pcntl php7-pdo_mysql php7-pdo_pgsql php7-pgsql php7-phar php7-posix \
	php7-redis \
	php7-session php7-simplexml php7-sodium php7-sqlite3 \
	php7-xml php7-xmlreader php7-xmlwriter \
	php7-zip php7-zlib

echo 'apc.enable_cli=1' >> /etc/php7/conf.d/apcu.ini
sed -i '/opcache.enable=1/a opcache.enable_cli=1' /etc/php7/php.ini

sed -i -e 's/;opcache.enable.*=.*/opcache.enable=1/g' \
-e 's/;opcache.interned_strings_buffer.*=.*/opcache.interned_strings_buffer=8/g' \
-e 's/;opcache.max_accelerated_files.*=.*/opcache.max_accelerated_files=10000/g' \
-e 's/;opcache.memory_consumption.*=.*/opcache.memory_consumption=128/g' \
-e 's/;opcache.save_comments.*=.*/opcache.save_comments=1/g' \
-e 's/;opcache.revalidate_freq.*=.*/opcache.revalidate_freq=1/g' \
-e 's/;always_populate_raw_post_data.*=.*/always_populate_raw_post_data=-1/g' \
-e 's/memory_limit.*=.*128M/memory_limit=512M/g' \
/etc/php7/php.ini

echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf
 
curl -fsSLo /srv/www/setup-nextcloud.php https://download.nextcloud.com/server/installer/setup-nextcloud.php

rm -rf /tmp/*
