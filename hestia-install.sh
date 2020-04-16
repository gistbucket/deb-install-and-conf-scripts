for SNIPPET in config-localus config-sshd echo-gitconfig list-installed remove-floppycdrom remove-packages remove-users set-timezone sysctl-redispostgres; do
  bash <(curl -sk https://raw.githubusercontent.com/JOduMonT/DEB/master/snippets/$SNIPPET)
done


for PASSWORD in HESTIAPWD REDISPWD ; do
 $PASSWORD=$(bash <(curl -sk https://raw.githubusercontent.com/JOduMonT/DEB/master/snippets/generate-24caracters))
done

wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh \
-a no \
-f -y no \
-g yes \
-k no \
-v no \
-w yes -o yes \
-x no -z no \
-c no -t no \
-s $(hostname -s).$(hostname -d) \
-e hostmaster@$(hostname -d) \
-p $HESTIAPWD

apt install -y curl php7.2-gmp php-imagick php-smbclient php-redis redis-server wget

sed 's|^port.*|port 0|' -i /etc/redis/redis.conf
sed 's|^# unixsocket .*|unixsocket /var/run/redis/redis.sock|' -i /etc/redis/redis.conf
sed 's|^# unixsocketperm .*|unixsocketperm 770|' -i /etc/redis/redis.conf
#sed "s|^# requirepass .*|requirepass $REDISPWD|" -i /etc/redis/redis.conf

for hUSER in $(grep hestia /etc/group|cut -d: -f4|sed 's/,/ /g'); do
usermod -aG redis $hUSER; done
systemctl restart redis
