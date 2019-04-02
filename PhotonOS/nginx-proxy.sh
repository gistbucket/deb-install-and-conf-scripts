#!/bin/bash

## ref: https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion

cd /srv
git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion.git /srv/webproxy

echo -e "version: '3'

services:

  nginx:
    image: nginx:alpine
    labels:
        com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    container_name: nginx
    restart: always
    ports:
      - 0.0.0.0:443:443/tcp
      - 0.0.0.0:80:80/tcp
    volumes:
      - /var/srv/webproxy/conf.d:/etc/nginx/conf.d
      - /var/srv/webproxy/vhost.d:/etc/nginx/vhost.d
      - /var/srv/webproxy/html:/usr/share/nginx/html
      - /var/srv/webproxy/log/nginx:/var/log/nginx
      - /var/srv/webproxy/certs:/etc/nginx/certs:ro
      - /var/srv/webproxy/htpasswd:/etc/nginx/htpasswd:ro
      - /var/run/php:/var/run/php
      
  docker-gen:
    depends_on:
      - nginx
    image: jwilder/docker-gen
    command: -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    container_name: docker-gen
    restart: always
    userns_mode: host
    volumes:
      - /var/srv/webproxy/conf.d:/etc/nginx/conf.d
      - /var/srv/webproxy/vhost.d:/etc/nginx/vhost.d
      - /var/srv/webproxy/html:/usr/share/nginx/html
      - /var/srv/webproxy/certs:/etc/nginx/certs:ro
      - /var/srv/webproxy/htpasswd:/etc/nginx/htpasswd:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro
      
  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt
    restart: always
    userns_mode: host
    volumes:
      - /var/srv/webproxy/conf.d:/etc/nginx/conf.d
      - /var/srv/webproxy/vhost.d:/etc/nginx/vhost.d
      - /var/srv/webproxy/html:/usr/share/nginx/html
      - /var/srv/webproxy/certs:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      NGINX_DOCKER_GEN_CONTAINER: docker-gen
      NGINX_PROXY_CONTAINER: nginx

networks:
  default:
    external:
      name: webproxy" > /srv/webproxy/docker-compose.yml


[[ -z $(docker network ls|grep webproxy) ]] && \
  docker network create webproxy

curl -o /srv/webproxy/nginx.tmpl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl

[[ ! -d /var/srv/webproxy ]] && \
    mkdir -p /var/srv/webproxy

[[ ! -d /var/srv/webproxy/conf.d ]] && \
    sudo cp -r /srv/webproxy/conf.d /var/srv/webproxy

cd /srv/webproxy
docker-compose up -d

sudo chmod 0644 /var/srv/webproxy/conf.d/default.conf

exit 0
