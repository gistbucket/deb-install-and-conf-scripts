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
    container_name: proxy
    restart: always
    ports:
      - 0.0.0.0:443:443/tcp
      - 0.0.0.0:80:80/tcp
    volumes:
      - /srv/data/webproxy/conf.d:/etc/nginx/conf.d
      - /srv/data/webproxy/vhost.d:/etc/nginx/vhost.d
      - /srv/data/webproxy/html:/usr/share/nginx/html
      - /srv/data/webproxy/log/nginx:/var/log/nginx
      - /srv/data/webproxy/certs:/etc/nginx/certs:ro
      - /srv/data/webproxy/htpasswd:/etc/nginx/htpasswd:ro
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
      - /srv/data/webproxy/conf.d:/etc/nginx/conf.d
      - /srv/data/webproxy/vhost.d:/etc/nginx/vhost.d
      - /srv/data/webproxy/html:/usr/share/nginx/html
      - /srv/data/webproxy/certs:/etc/nginx/certs:ro
      - /srv/data/webproxy/htpasswd:/etc/nginx/htpasswd:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro
      
  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt
    restart: always
    userns_mode: host
    volumes:
      - /srv/data/webproxy/conf.d:/etc/nginx/conf.d
      - /srv/data/webproxy/vhost.d:/etc/nginx/vhost.d
      - /srv/data/webproxy/html:/usr/share/nginx/html
      - /srv/data/webproxy/certs:/etc/nginx/certs:rw
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

[[ ! -d /srv/data/webproxy ]] && \
    mkdir -p /srv/data/webproxy

[[ ! -d /srv/data/webproxy/conf.d ]] && \
    sudo cp -r /srv/webproxy/conf.d /srv/data/webproxy

cd /srv/webproxy
docker-compose up -d

chmod 0644 /srv/data/webproxy/conf.d/default.conf

exit 0
