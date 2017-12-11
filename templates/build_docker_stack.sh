#!/bin/sh

SUDO=""
if type "sudo" > /dev/null 2>&1
then
  SUDO="sudo"
fi

FQDN="releases.usacloud.jp"
if [ -s fqdn ]; then
  FQDN="`cat fqdn`"
fi

RELEASES_FRONT_TAG="latest"
RELEASES_TERRAFORM_TAG="latest"
RELEASES_USACLOUD_TAG="latest"
RELEASES_DOCKER_MACHINE_TAG="latest"
WEBSITE_USACLOUD_TAG="latest"

if [ -s versions/releases-front-web ]; then
  RELEASES_FRONT_TAG="`cat versions/releases-front-web`"
fi
if [ -s versions/releases-terraform ]; then
  RELEASES_TERRAFORM_TAG="`cat versions/releases-terraform`"
fi
if [ -s versions/releases-usacloud ]; then
  RELEASES_USACLOUD_TAG="`cat versions/releases-usacloud`"
fi
if [ -s versions/releases-docker-machine ]; then
  RELEASES_DOCKER_MACHINE_TAG="`cat versions/releases-docker-machine`"
fi
if [ -s versions/usacloud-website ]; then
  WEBSITE_USACLOUD_TAG="`cat versions/usacloud-website`"
fi

$SUDO cat > docker-compose.yml <<EOF
version: "3.1"

services:
  https-portal:
    image: steveltn/https-portal:1.1
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - $BASEDIR/certs:/var/lib/https-portal
    environment:
      DOMAINS: '$FQDN -> http://releases-front-web'
      STAGE: 'production'
      # FORCE_RENEW: 'true'
    networks:
      - "front-public"
    logging:
      driver: syslog
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
  releases-front-web:
    image: "sacloud/releases-front-web:$RELEASES_FRONT_TAG"
    networks:
      - "front-public"
    deploy:
      mode: global
    logging:
      driver: syslog
    secrets:
      - htpasswd
  releases-terraform:
    image: "sacloud/releases-terraform:$RELEASES_TERRAFORM_TAG"
    networks:
      - "front-public"
    deploy:
      mode: global
    logging:
      driver: syslog
  releases-usacloud:
    image: "sacloud/releases-usacloud:$RELEASES_USACLOUD_TAG"
    networks:
      - "front-public"
    deploy:
      mode: global
    logging:
      driver: syslog
  releases-docker-machine:
    image: "sacloud/releases-docker-machine:$RELEASES_DOCKER_MACHINE_TAG"
    networks:
      - "front-public"
    deploy:
      mode: global
    logging:
      driver: syslog
  usacloud-website:
    image: "sacloud/usacloud-website:$WEBSITE_USACLOUD_TAG"
    networks:
      - "front-public"
    deploy:
      mode: global
    logging:
      driver: syslog
secrets:
  htpasswd:
    file: .htpasswd
networks:
  front-public:
    driver: "overlay"
EOF

docker stack deploy -c docker-compose.yml usacloud