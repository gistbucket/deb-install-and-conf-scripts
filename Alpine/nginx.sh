ref: https://wiki.alpinelinux.org/wiki/Nginx

wget -P /tmp https://raw.githubusercontent.com/jodumont/ScRIPtS/master/Alpine/lxc-client-init.sh
sh /tmp/lxc-client-init.sh

apk update
apk add --no-cache \
  bash bzip2 \
  ca-certificates coreutils curl \
  shadow \
  tar tzdata \
  unzip \
  xz \
  wget
  
apk update
apk add --no-cache \
  nginx

useradd -MUs /sbin/nologin www

mkdir /srv/www
chown -R www:www /var/lib/nginx
chown -R www:www /srv/www

cat << EOF > /etc/nginx/nginx.conf
user www;
worker_processes auto; # it will be determinate automatically by the number of core

error_log /var/log/nginx/error.log warn;
#pid /var/run/nginx.pid; # it permit you to use /etc/init.d/nginx reload|restart|stop|start

events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  access_log /var/log/nginx/access.log;
  keepalive_timeout 3000;

  server {
    listen 80;
    root /srv/www;
    index index.html;
    server_name localhost;
    client_max_body_size 32m;
    
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
      root /var/lib/nginx/html;
    }
  }
}
EOF

cat << EOF > /srv/www/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>HTML5</title>
  </head>
  <body>
    Server is online
  </body>
</html>
EOF

rc-update add nginx default
rc-service nginx start
