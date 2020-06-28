for SCRIPT in config-locale-en_us dist-upgrade install-{autoupdate,base} config-{autoupdate,dpkg,timedatectl} clean-{apt,history} ; do
  wget -qO /tmp/$SCRIPT https://raw.githubusercontent.com/JOduMonT/DEB/master/snippets/$SCRIPT;
  bash /tmp/$SCRIPT;
done
systemctl disable ssh
