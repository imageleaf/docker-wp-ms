#!/bin/bash

VERSION_LIST=('5.6' '7.0' '7.1')

# Alpine based
for version in '5.6' '7.0' '7.1'; do
    dirname="docker/php${version}/fpm-alpine"
    mkdir -p "${dirname}"
    base="php${version}-fpm-alpine"
    dockerfile="${dirname}/Dockerfile"
    echo -e "FROM wordpress:${base}\n" > "${dockerfile}"
    echo "$(cat Dockerfile-alpine)" >> "${dockerfile}"
done

# Debian based
for version in '5.6' '7.0' '7.1'; do
    for variant in 'apache' 'fpm'; do
        dirname="docker/php${version}/${variant}"
        mkdir -p "${dirname}"
        base="php${version}-${variant}"
        dockerfile="${dirname}/Dockerfile"
        echo -e "FROM wordpress:${base}\n" > "${dockerfile}"
        echo "$(cat Dockerfile-debian)" >> "${dockerfile}"
    done
done
