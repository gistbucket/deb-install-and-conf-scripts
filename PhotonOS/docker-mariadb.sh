CONTAINER=mariadb
IMAGE=mariadb

[[ -f ${DATA:-/var/srv}/.env ]] && \
  source ${DATA:-/var/srv}/.env

[[ -z ${NETWORK} ]] && \
  NETWORK=db_${CONTAINER}

[[ -z $(docker network ls|grep ${NETWORK}) ]] && \
docker network create ${NETWORK} \
  --internal \
  --subnet=172.33.6.0/24

[[ ! -f ${DATA:-/var/srv}/${CONTAINER}/.secret ]] && \
  mkdir ${DATA:-/var/srv}/${CONTAINER} && \
  PASSWORD=$(</dev/urandom tr -dc '12345!@%_.qwertYUIOPasdfgHJKLzxcvBNM'|head -c24) && \
  echo "ROOT_PASSWORD=$PASSWORD" > ${DATA:-/var/srv}/${CONTAINER}/.secret && \
  chmod 400 ${DATA:-/var/srv}/${CONTAINER}/.secret
  source ${DATA:-/var/srv}/${CONTAINER}/.secret

docker stop ${CONTAINER}
docker rm ${CONTAINER}
docker pull ${IMAGE}

docker run -d \
  -e MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD \
  -v ${DATA:-/var/srv}/${CONTAINER}/mysql:/var/lib/mysql \
  --cpu-shares=${CPUS:-1000} \
  --ip=172.33.6.254 \
  --memory ${MEM:-1536M} \
  --name ${CONTAINER} \
  --pids-limit=${PIDS:-100} \
  --network=${NETWORK} \
  --restart unless-stopped \
  --security-opt no-new-privileges \
  ${IMAGE}

[[ -n $(grep DOCKREMAPID ${DATA:-/var/srv}/.env) ]] && \
  sudo chown $((999+${DOCKREMAPID})):$((999+${DOCKREMAPID})) ${DATA:-/var/srv}/${CONTAINER}/mysql/.
