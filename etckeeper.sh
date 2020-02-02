#!/bin/bash -eux

## VARIABLES
PRIVATEREPO="" # git@github.com:GitUser/etc-host.domain.tld.git

apt install -y etckeeper

sed -i "s/^VCS=.*/VCS=\"git\"/" /etc/etckeeper/etckeeper.conf
sed -i "s/^PUSH_REMOTE=.*/PUSH_REMOTE=\"origin\"/" /etc/etckeeper/etckeeper.conf

mkdir -p /etc/.github/ISSUE_TEMPLATE/
wget -O /etc/.github/ISSUE_TEMPLATE/bug_report.md https://raw.githubusercontent.com/JOduMonT/.dotfile/master/.github/ISSUE_TEMPLATE/bug_report.md
wget -O /etc/.github/ISSUE_TEMPLATE/feature_request.md https://raw.githubusercontent.com/JOduMonT/.dotfile/master/.github/ISSUE_TEMPLATE/feature_request.md

cd /etc
etckeeper init
etckeeper add /etc/.github/ISSUE_TEMPLATE/*
etckeeper commit -m "init"
git remote add origin ${PRIVATEREPO}
git push -u origin master
