PASSWORD=
REDISPWD=

export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C

wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh \
-a no \
-k no \
-w yes -o yes \
-s $(hostname -s).$(hostname -d) \
-e hostmaster@$(hostname -d) \
-p $PASSWORD

echo -e "[user]
        name = $(hostname -s)
        email = hostmaster@$(hostname -d)" > /root/.gitconfig

apt install -y etckeeper php-imagick php-smbclient php-redis redis-server

[[ -z $REDISPWD ]] && \
REDISPWD=$(openssl rand --base64 24)
sed 's|^port.*|port 0|' -i /etc/redis/redis.conf
sed 's|^# unixsocket .*|unixsocket /var/run/redis/redis.sock|' -i /etc/redis/redis.conf
sed 's|^# unixsocketperm .*|unixsocketperm 770|' -i /etc/redis/redis.conf
sed "s|^# requirepass .*|requirepass $REDISPWD|" -i /etc/redis/redis.conf

for hUSER in $(grep hestia /etc/group|cut -d: -f4|sed 's/,/ /g'); do
usermod -aG redis $hUSER; done
systemctl restart redis
