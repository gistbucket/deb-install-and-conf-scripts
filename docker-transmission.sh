#!/bin/bash -eux

USER=
PASSWORD=

CONTAINER=transmission
IMAGE=linuxserver/transmission
PUID=$(id|cut -d= -f2|cut -d\( -f1)
PGID=$(id|cut -d= -f3|cut -d\( -f1)

source .env

docker stop ${CONTAINER}
docker rm ${CONTAINER}
docker pull ${IMAGE}

docker run -d \
  --name=${CONTAINER} \
  -e PUID=${PUID} \
  -e PGID=${PGID} \
  -e TZ=${TZ:-Europe/Amsterdam} \
  -e USER=${USER} \
  -e PASS=${PASSWORD} \
  -p 9091:9091/tcp \
  -p 51413:51413/tcp \
  -p 51413:51413/udp \
  -v ${STORAGE:-/srv}/config/${CONTAINER}:/config \
  -v ${STORAGE:-/srv}/downloads:/downloads \
  -v ${STORAGE:-/srv}/watch:/watch \
  --restart always \
  ${IMAGE}

[[ -z $(grep '"blocklist-enabled": true,' ${STORAGE:-/srv}/config/${CONTAINER}/settings.json) ]] && \
  docker stop ${CONTAINER} && \
  sed 's|"blocklist-enabled":.*|"blocklist-enabled": true,|g' -i ${STORAGE:-/srv}/config/${CONTAINER}/settings.json && \
  sed 's|"blocklist-url":.*|"blocklist-url": "http://john.bitsurge.net/public/biglist.p2p.gz",|g' -i ${STORAGE:-/srv}/config/${CONTAINER}/settings.json && \
  docker restart ${CONTAINER}
  
