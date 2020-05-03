apt install -y apt-transport-https curl dirmngr wget

rm -f /etc/apt/sources.list.d/sources.list
echo "deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://deb.debian.org/debian-security stretch/updates main contrib non-free
deb http://ftp.debian.org/debian stretch-backports main contrib non-free"> /etc/apt/sources.list

echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list

wget -qO- http://www.webmin.com/jcameron-key.asc | apt-key add

apt update
apt upgrade -y
