apt install -y apt-transport-https ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
apt update
