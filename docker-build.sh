#!/bin/bash

VERSION_LIST=('5.6' '7.0' '7.1', '7.2')
declare -A VARIANT_LIST
VARIANT_LIST=(
    ['apache']='debian'
    ['cli']='alpine-cli'
    ['fpm']='debian'
    ['fpm-alpine']='alpine'
)

for version in "${VERSION_LIST[@]}"; do
    for variant in "${!VARIANT_LIST[@]}"; do
        dirname="docker/php${version}/${variant}"
        mkdir -p "${dirname}"
        base="php${version}-${variant}"
        if [ "${variant}" == "cli" ]; then
            base="${variant}-php${version}"
        fi
        echo "Creating Dockerfile for ${base}"
        dockerfile="${dirname}/Dockerfile"
        echo -e "FROM wordpress:${base}\n" > "${dockerfile}"
        base_dockerfile="Dockerfile-${VARIANT_LIST[$variant]}"
        echo "$(cat $base_dockerfile)" >> "${dockerfile}"
        docker pull "wordpress:${base}"
        docker build -t "wordpress:${base}" "${dirname}" 2>&1 > "docker_build_${base}.log"
        result=$?
        if [ "x${result}" != "x0" ]; then
            echo "Failed building image for ${base}"
        else
            echo "Building image for ${base} succeeded"
        fi
        docker rmi "wordpress:${base}"
    done
done
