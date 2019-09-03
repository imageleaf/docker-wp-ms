#!/bin/bash

VERSION_LIST=('5.6' '7.2' '7.3')
declare -A VARIANT_LIST
VARIANT_LIST=(
    ['cli']='alpine-cli'
    ['fpm']='debian'
    ['fpm-alpine']='alpine'
)

for version in "${VERSION_LIST[@]}"; do
    for variant in "${!VARIANT_LIST[@]}"; do
        base="php${version}-${variant}"
        if [[ "${variant}" == "cli" ]]; then
            base="${variant}-php${version}"
        fi
        echo "Creating Dockerfile for ${base}"
        base_dockerfile="Dockerfile-${VARIANT_LIST[$variant]}"
        dockerfile_content=$(sed -e "s/PHP_VERSION/${version}/" "${base_dockerfile}")
        docker pull "wordpress:${base}"
        new_image_tag="yehuda/wordpress:${base}"
        echo -e "FROM wordpress:${base}\n${dockerfile_content}" | docker build -t "${new_image_tag}" - 2>&1 > "docker_build_${base}.log"
        result=$?
        if [[ "x${result}" != "x0" ]]; then
            echo 1>&2 "Failed building image for ${base}"
            echo 1>&2 "Image kept on local disk for inspection"
        else
            echo "Building image for ${base} succeeded"
            docker push "${new_image_tag}"
            docker image rm "${new_image_tag}" "wordpress:${base}"
        fi
    done
done

# Build nginx image
echo "Creating Dockerfile for nginx:alpine"
docker build -t 'yehuda/wp-nginx:latest' nginx 2>&1 > "docker_build_nginx.log"
result=$?
if [[ "x${result}" != "x0" ]]; then
    echo 1>&2 "Failed building image for nginx:alpine"
    echo 1>&2 "Image kept on local disk for inspection"
else
    echo "Building image for nginx:alpine succeeded"
    docker push 'yehuda/wp-nginx:latest'
    docker image rm 'yehuda/wp-nginx:latest'
fi
