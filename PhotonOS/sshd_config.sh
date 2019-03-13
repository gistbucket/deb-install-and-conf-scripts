#!/bin/bash

curl -o /etc/ssh/sshd_config -L https://git.io/fhhzL
sed -i 's/AllowGroups ssh/AllowGroups sshd/g' /etc/ssh/sshd_config
systemctl restart sshd
