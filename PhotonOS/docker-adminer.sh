CONTAINER=adminer
IMAGE=adminer

docker stop ${CONTAINER}
docker rm ${CONTAINER}
docker pull ${IMAGE}

docker run -d \
  -p 8080:8080/tcp \
  --cpu-shares=${CPUS:-500} \
  --memory ${MEM:-64M} \
  --name ${CONTAINER} \
  --pids-limit=${PIDS:-100} \
  --restart unless-stopped \
  --security-opt no-new-privileges \
  ${IMAGE}

for DB in $(docker network ls|grep db_|cut -d_ -f2|cut -d' ' -f1);
do
  docker network connect db_${DB} ${CONTAINER}
done
