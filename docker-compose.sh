DockerComposeVersion="$(curl -fsSL https://github.com/docker/compose/releases/latest|grep Release|grep title|rev|cut -d' ' -f5|rev)"

curl -L "https://github.com/docker/compose/releases/download/${DockerComposeVersion}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chown :docker /usr/local/bin/docker-compose
chmod 750 /usr/local/bin/docker-compose
