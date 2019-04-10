# ref: http://nginx.org/en/linux_packages.html#Debian

apt install -y curl gnupg2 ca-certificates lsb-release

echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" > /etc/apt/sources.list.d/nginx.list

curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

apt update
apt install nginx
