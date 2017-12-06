#!/bin/bash

for version in '5.6' '7.0' '7.1'; do
    for variant in 'apache' 'cli' 'fpm-alpine' 'fpm'; do
        dirname="docker/php${version}/${variant}"
        mkdir -p "${dirname}"
        base="php${version}-${variant}"
        dockerfile="${dirname}/Dockerfile"
        echo -e "FROM wordpress:${base}\n" > "${dockerfile}"
        echo "$(cat Dockerfile)" >> "${dockerfile}"
    done
done
