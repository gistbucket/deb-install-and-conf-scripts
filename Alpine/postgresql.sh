PGUSERDB=
PGPASSWD=$(openssl rand -base64 24)
PGDB=${PGUSERDB}
PGVERS=$(psql -V|cut -d' ' -f3)

mkdir /srv/postgresql
ls -fs /srv/postgresql /var/lib/postgresql

apk add --no-cache --upgrade \
  postgresql postgresql-client

curl -fsSLo /var/lib/postgresql/${PGVERS}/data/pg_hba.conf https://raw.githubusercontent.com/jodumont/ConFig/master/var/lib/postgresql/data/pg_hba.conf

/etc/init.d/postgresql setup
/etc/init.d/postgresql start

[[ -z ${PGUSERDB} ]] && \
exit 0

psql -U postgres -c "CREATE USER ${NEXTCLOUDDB} WITH PASSWORD '${PGPASSWD}';"
psql -U postgres -c "ALTER ROLE ${NEXTCLOUDDB} CREATEDB;"
psql -U postgres -c "CREATE ROLE ${NEXTCLOUDDB} WITH LOGIN PASSWORD ${PGPASSWD};"
psql -U postgres -c "CREATE DATABASE ${NEXTCLOUDDB} OWNER ${NEXTCLOUDDB};"
