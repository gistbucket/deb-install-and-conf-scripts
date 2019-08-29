apt install -y arpon

echo "
DAEMON_OPTS=\"-q -f /var/log/arpon/arpon.log -g -D\"
RUN=\"yes\"
" > /etc/default/arpon

systemctl enable arpon
systemctl restart arpon
