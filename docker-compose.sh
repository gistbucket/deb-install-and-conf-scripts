DockerComposeVersion="$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1)"

curl -L "https://github.com/docker/compose/releases/download/${DockerComposeVersion}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chown :docker /usr/local/bin/docker-compose
chmod 750 /usr/local/bin/docker-compose
