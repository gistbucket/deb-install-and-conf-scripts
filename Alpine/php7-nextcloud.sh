#ref: https://docs.nextcloud.com/server/15/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
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
