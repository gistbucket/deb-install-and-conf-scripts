ref: https://wiki.alpinelinux.org/wiki/Nginx

curl -fsSLo /tmp/base.sh https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/base.sh
sh /tmp/base.sh

apk add --no-cache --update \
  nginx

useradd -MUs /sbin/nologin www

mkdir /etc/nginx/sites-{available,enabled} /srv/www
chown -R www:www /var/lib/nginx /srv/www

path=/etc/nginx
for file in {nginx.conf,conf.d/{{gzip,letsencrypt,security}.server,proxy.location,ssl.http},sites-available/example.com}; do
  curl -fsSLo $path/$file https://raw.githubusercontent.com/jodumont/ConFig/master/$path/$file
done

curl -fsSLo /srv/www/index.html https://raw.githubusercontent.com/jodumont/ConFig/master/www/index.html

rc-update add nginx default
rc-service nginx start
