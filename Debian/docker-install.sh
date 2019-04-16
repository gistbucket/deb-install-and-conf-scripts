#!/bin/bash

sudo apt-get remove -y \
  containerd \
  docker docker-engine docker.io \
  runc

sudo apt-get install \
  apt-transport-https \
  ca-certificates curl \
  gnupg2 \
  software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update

sudo apt-get install -y \
  containerd.io \
  docker-ce docker-ce-cli

sudo apt remove --purge -y \
  aufs*
