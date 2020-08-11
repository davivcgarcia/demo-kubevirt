#! /usr/bin/bash

CONTAINER_NAME=local-repo
NGINX_IMAGE_DIR=`pwd`/images
NGINX_CONF_DIR=`pwd`/nginx-conf.d

if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    docker run -d --rm --name $CONTAINER_NAME -p 8080:80 -v $NGINX_IMAGE_DIR:/srv/images -v $NGINX_CONF_DIR:/etc/nginx/conf.d/ --network kind nginx
fi
