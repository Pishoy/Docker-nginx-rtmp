#!/bin/sh

NGINX_CONFIG_FILE=/opt/nginx/conf/nginx.conf


RTMP_CONNECTIONS=${RTMP_CONNECTIONS-1024}
RTMP_STREAM_NAMES=${RTMP_STREAM_NAMES-live,testing}
RTMP_STREAMS=$(echo ${RTMP_STREAM_NAMES} | sed "s/,/\n/g")
RTMP_PUSH_URLS=$(echo ${RTMP_PUSH_URLS} | sed "s/,/\n/g")

apply_config() {

    echo "Creating config"
## Standard config:

cat >${NGINX_CONFIG_FILE} <<!EOF
worker_processes 1;

events {
    worker_connections ${RTMP_CONNECTIONS};
}
!EOF


## RTMP Config
cat >>${NGINX_CONFIG_FILE} <<!EOF
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
!EOF

if [ "x${RTMP_PUSH_URLS}" = "x" ]; then
    PUSH="false"
else
    PUSH="true"
fi


for STREAM_NAME in $(echo ${RTMP_STREAMS}) 
do

echo Creating stream $STREAM_NAME
cat >>${NGINX_CONFIG_FILE} <<!EOF
        application ${STREAM_NAME} {
            live on;
            record off;
!EOF

if [ "$PUSH" = "true" ]; then
        for PUSH_URL in $(echo ${RTMP_PUSH_URLS}); do
            echo "Pushing stream to ${PUSH_URL}"
            cat >>${NGINX_CONFIG_FILE} <<!EOF
            push ${PUSH_URL};
!EOF
            PUSH=false
        done
    fi
cat >>${NGINX_CONFIG_FILE} <<!EOF
        }
!EOF
done

cat >>${NGINX_CONFIG_FILE} <<!EOF
    }
}
!EOF
}

if ! [ -f ${NGINX_CONFIG_FILE} ]; then
    apply_config
else
    echo "CONFIG EXISTS - Not creating!"
fi

echo "Starting server"
/opt/nginx/sbin/nginx -g "daemon off;"
