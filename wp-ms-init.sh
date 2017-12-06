#!/bin/bash

ENV_FILES=("mariadb.env" "wordpress.env" "wp-ms-init.env")

ok=1
for env_file in ${ENV_FILES[@]}; do
    if [ ! -e "${env_file}" ]; then
        echo "ENV file ${env_file} is missing"
        ok=0
    fi
done

if [ "x${ok}" = "x0" ]; then
    exit
fi

# Get default from environment, so you can pass things like "-f docker-compose-dev.yml"
DOCKER_ARGS="${DOCKER_ARGS}"

echo 'Bringing up the Database'
docker-compose ${DOCKER_ARGS} up -d db

sleep 5

echo 'Bringing up the Wordpress instance'
docker-compose ${DOCKER_ARGS} up -d wordpress

sleep 3

# wp core multisite-install
#   [--url=<url>]
#   [--base=<url-path>]
#   [--subdomains]
#   --title=<site-title>
#   --admin_user=<username>
#   [--admin_password=<password>]
#   --admin_email=<email>
#   [--skip-email]
#   [--skip-config]

source wp-ms-init.env

echo 'Setting up multi-site'
docker-compose ${DOCKER_ARGS} run --rm cli wp core multisite-install \
    --subdomains \
    --url="${URL}" \
    --title="${TITLE}" \
    --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}" \
    --skip-email \
    --quiet

echo 'Bringing up the Nginx HTTP server'
docker-compose ${DOCKER_ARGS} up -d web

echo 'In order to save space, Run this after pulling new version of docker images:'
echo "  docker images -a | awk '{print \$3}' | xargs -n 1 docker rmi"
