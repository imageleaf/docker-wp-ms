#!/bin/bash

VERSION_LIST=('5.6' '7.2' '7.3')
declare -A TARGET_TAG_VARIANT_MAP
TARGET_TAG_VARIANT_MAP=(
    ['cron']='cli'
    ['cli']='cli'
    ['fpm']='fpm'
    ['fpm-alpine']='fpm-alpine'
)

# Build wordpress images
for version in "${VERSION_LIST[@]}"; do
    for target_variant in "${!TARGET_TAG_VARIANT_MAP[@]}"; do
        base_variant=${TARGET_TAG_VARIANT_MAP[$target_variant]}
        base_tag="php${version}-${base_variant}"
        target_tag="php${version}-${target_variant}"
        if [[ "${base_variant}" == "cli" ]]; then
            base_tag="${base_variant}-php${version}"
            target_tag="${target_variant}-php${version}"
        fi
        echo "Creating Dockerfile for ${base_tag}"
        base_dockerfile="Dockerfile-${target_variant}"
        dockerfile_content=$(sed -e "s/PHP_VERSION/${version}/" "${base_dockerfile}")
        docker pull "wordpress:${base_tag}"
        new_image_tag="yehuda/wordpress:${target_tag}"
        echo -e "FROM wordpress:${base_tag}\n${dockerfile_content}" | docker build -t "${new_image_tag}" - 2>&1 > "docker_build_${base_tag}.log"
        result=$?
        if [[ "x${result}" != "x0" ]]; then
            echo 1>&2 "Failed building image for ${target_tag}"
            echo 1>&2 "Image kept on local disk for inspection"
        else
            echo "Building image for ${target_tag} succeeded"
            docker push "${new_image_tag}"
            docker image rm "${new_image_tag}"
        fi
    done
done

for version in "${VERSION_LIST[@]}"; do
    for target_variant in "${!TARGET_TAG_VARIANT_MAP[@]}"; do
        base_variant=${TARGET_TAG_VARIANT_MAP[$target_variant]}
        base_tag="php${version}-${base_variant}"
        if [[ "${base_variant}" == "cli" ]]; then
            base_tag="${base_variant}-php${version}"
        fi
        docker image rm "wordpress:${base_tag}"
    done
done


# Build nginx image
echo "Creating Dockerfile for nginx:alpine"
today=$(date +%Y%m%d)
docker build -t "yehuda/wp-nginx:${today}" nginx 2>&1 > "docker_build_nginx.log"
result=$?
if [[ "x${result}" != "x0" ]]; then
    echo 1>&2 "Failed building image for nginx:alpine"
    echo 1>&2 "Image kept on local disk for inspection"
else
    echo "Building image for nginx:alpine succeeded"
    docker tag "yehuda/wp-nginx:${today}" 'yehuda/wp-nginx:latest'
    docker push "yehuda/wp-nginx:${today}"
    docker push 'yehuda/wp-nginx:latest'
    docker image rm 'nginx:alpine' "yehuda/wp-nginx:${today}" 'yehuda/wp-nginx:latest'
fi
