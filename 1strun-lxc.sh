for SCRIPT in dist-upgrade install-autoupdate config-{autoupdate,dpkg,locale-en_us,lxc,timedatectl} clean-{apt,history} ; do
  wget -qO /tmp/$SCRIPT https://raw.githubusercontent.com/JOduMonT/DEB/master/snippets/$SCRIPT;
  bash /tmp/$SCRIPT;
done
