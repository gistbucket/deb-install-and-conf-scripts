#!/bin/bash

dcVer=$(curl -s https://docs.docker.com/compose/install/|grep -m 1 'Compose, substitute'|cut -d\> -f3|cut -d\< -f1)

[[ $(id -u) == "0" ]] && \
  echo "Please run this script as a user."
  exit 0

[[ -z $(grep "sudo.*.$USER" /etc/group) ]] && \
  echo "ERROR your user is not member of sudo group"
  exit 0

[[ -n $(grep "sudo.*.$USER" /etc/group) ]] && \
  sudo curl -L "https://github.com/docker/compose/releases/download/${dcVer}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  sudo chmod +x /usr/local/bin/docker-compose
