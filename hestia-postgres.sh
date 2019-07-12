# ref: https://github.com/hestiacp/hestiacp/blob/master/install/hst-install-debian.sh#L1416

# Defining password-gen function
gen_pass() {
    MATRIX='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    LENGTH=16
    while [ ${n:=1} -le $LENGTH ]; do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done
    echo "$PASS"
}
ppass=$(gen_pass)
    
apt install -y postgresql postgresql-contrib
wget -O /etc/postgresql/*/main/pg_hba.conf https://raw.githubusercontent.com/hestiacp/hestiacp/master/install/deb/postgresql/pg_hba.conf
systemctl restart postgresql
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$ppass'"

sed "s/^DB_SYSTEM=''/DB_SYSTEM='pgsql'/" -i /usr/local/hestia/conf/hestia.conf
sed "s/^DB_SYSTEM='mysql'/DB_SYSTEM='mysql,pgsql'/" -i /usr/local/hestia/conf/hestia.conf

/usr/local/hestia/bin/v-add-database-host pgsql localhost postgres $ppass
systemctl restart hestia
