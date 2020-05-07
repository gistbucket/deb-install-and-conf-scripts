MARIADB_VS=   # Default = 10.4
NODEJS_VS=    # Default = 10.x


export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

apt update
apt upgrade -y

## REQUIREMENTS
[[ $(lsb_release -sr) == 18.04 ]] && \
  apt install -y curl g++ gcc git libffi-dev libssl-dev make python-pip python-dev redis-server software-properties-common wkhtmltopdf
[[ $(lsb_release -sr) == 20.04 ]] && \
  apt install -y curl g++ gcc git libffi-dev libssl-dev make python3-pip python3-dev python3-testresources redis-server software-properties-common wkhtmltopdf

## NODEJS
curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo "deb https://deb.nodesource.com/node_${NODEJS_VS:-10.x} $(lsb_release -sc) main" > /etc/apt/sources.list.d/nodesource.list
apt update
apt install -y nodejs
npm install -g yarn

## NGINX
curl -sSL https://nginx.org/packages/keys/nginx_signing.key | apt-key add -
echo "deb https://nginx.org/packages/ubuntu/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list
apt update
apt install -y nginx

## MARIADB
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
[[ $(lsb_release -sr) == 18.04 ]] && \
  echo "deb [arch=amd64] http://mirror.ehv.weppel.nl/mariadb/repo/${MARIADB_VS:-10.4}/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/mariadb.list
apt update
apt install -y mariadb-server

mysql -u root
USE mysql;
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;
EXIT;

echo -e "[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation_server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4" > /etc/mysql/mariadb.conf.d/99-erpnext.cnf
systemctl restart mariadb

useradd -ms /bin/bash erpnext
usermod -aG sudo erpnext

mkdir /srv/bench
chown -R erpnext /srv/bench

su - erpnext
tee -a ~/.bashrc<<EOF
PATH=\$PATH:~/.local/bin/
EOF
source ~/.bashrc

## BENCH
cd /srv/bench
git clone https://github.com/frappe/bench bench-repo
[[ $(lsb_release -sr) == 18.04 ]] && \
  pip install -e bench-repo
[[ $(lsb_release -sr) == 20.04 ]] && \
  pip3 install -e bench-repo

bench init erpnext

pip install frappe-bench
