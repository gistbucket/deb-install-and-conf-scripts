
PASSWORD=

export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C

wget https://raw.githubusercontent.com/hestiacp/hestiacp/master/install/hst-install.sh
bash hst-install.sh \
-a no \
-w yes -o yes \
-s $(hostname -s).$(hostname -d) \
-e hostmaster@$(hostname -d) \
-p $PASSWORD

echo -e "[user]
        name = $(hostname -s)
        email = hostmaster@$(hostname -d)" > /root/.gitconfig

apt install -y etckeeper php-imagick php-smbclient php-redis redis-server

cd /usr/local/hestia
git init
git -A
git commit -m "Hestia Fresh Install"

apt remove -y --purge webalizer
sed 's/webalizer,//' -i /usr/local/hestia/conf/hestia.conf

sed 's/group = $1/group = www-data/' -i /usr/local/hestia/data/templates/web/nginx/PHP-*.sh
sed 's/listen.mode = 0666/listen.mode = 0660/' -i /usr/local/hestia/data/templates/web/nginx/PHP-*.sh
