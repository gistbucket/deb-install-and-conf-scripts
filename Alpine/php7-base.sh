ref: https://wiki.alpinelinux.org/wiki/Nginx

wget -P /tmp https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/nginx.sh
sh /tmp/nginx.sh

apk add --update --no-cache \
  php7-ctype php7-curl \
  php7-fpm \
  php7-gd \
  php7-iconv php7-intl \
  php7-json \
  php7-mbstring \
  php7-openssl \
  php7-session \
  php7-xml \
  php7-zlib
