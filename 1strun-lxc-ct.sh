/usr/bin/env DEBIAN_FRONTEND=noninteractive
for SCRIPT in dist-upgrade install-{autoupdate,base} config-{autoupdate,dpkg,locale-en_us,timedatectl} clean-{apt,history} ; do
  wget -qO /tmp/$SCRIPT https://raw.githubusercontent.com/JOduMonT/DEB/master/snippets/$SCRIPT;
  bash /tmp/$SCRIPT;
done
systemctl disable ssh
