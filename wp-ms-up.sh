#!/bin/bash
ENV_FILES=("wp-ms-init.env")

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

echo 'Pulling latest wordpress docker image'
docker-compose ${DOCKER_ARGS} pull wordpress

echo 'Recreating wordpress with the latest image'
docker-compose ${DOCKER_ARGS} up -d wordpress

echo 'In order to save space, Run this after pulling new version of docker images:'
echo "  docker images -a | awk '{print \$3}' | xargs -n 1 docker rmi"
