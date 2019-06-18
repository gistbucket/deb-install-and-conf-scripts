DOMAIN=

wget https://raw.githubusercontent.com/hestiacp/hestiacp/master/install/hst-install.sh

## WEB ONLY (LEMP) +MultiPHP
## NO APACHE, DNS and MAIL SERVICES

bash hst-install.sh \
-a no \
-w yes -o yes \
-v no \
-k no \
-x no -z no -c no -t no \
-s $(hostname -s).$DOMAIN \
-e hostmaster@$DOMAIN

## ADD REDIS
apt install -y git php-imagick php-smbclient php-redis redis-server

see: https://github.com/hestiacp/hestiacp/issues/337#issuecomment-503344508
