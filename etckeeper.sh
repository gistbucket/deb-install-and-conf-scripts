#!/bin/bash -eux

## VARIABLES
PRIVATEREPO="" # git@github.com:GitUser/etc-host.domain.tld.git

apt install -y etckeeper

sed -i "s/^VCS=.*/VCS=\"git\"/" /etc/etckeeper/etckeeper.conf
sed -i "s/^PUSH_REMOTE=.*/PUSH_REMOTE=\"origin\"/" /etc/etckeeper/etckeeper.conf

cd /etc
git remote add origin ${PRIVATEREPO}
git push -u origin master
exit
