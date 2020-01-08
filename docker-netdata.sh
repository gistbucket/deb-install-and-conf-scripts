#!/bin/bash -eux

CONTAINER=netdata
IMAGE=netdata/netdata
HOSTNAME=$(hostname -f)

docker stop ${CONTAINER}
docker rm ${CONTAINER}
docker pull ${IMAGE}

docker run -d \
  --name=${CONTAINER:-netdata} \
  --hostname=${HOSTNAME} \
  -p 19999:19999 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  --restart always \
  ${IMAGE}
