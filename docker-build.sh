#!/bin/bash

VERSION_LIST=('5.6' '7.2' '7.3')
declare -A TARGET_TAG_VARIANT_MAP
TARGET_TAG_VARIANT_MAP=(
    ['cron']='cli'
    ['cli']='cli'
    ['fpm']='fpm'
    ['fpm-alpine']='fpm-alpine'
)

BASE_REGISTRY_REPO='wordpress'
TARGET_REGISTRY_REPO='yehuda/wordpress'
DATE_TAG=`date +%Y%m%d`

# Build wordpress images
for version in "${VERSION_LIST[@]}"; do
    for target_variant in "${!TARGET_TAG_VARIANT_MAP[@]}"; do
        base_variant=${TARGET_TAG_VARIANT_MAP[$target_variant]}
        base_tag="php${version}-${base_variant}"
        target_tag="php${version}-${target_variant}"
        if [[ "${base_variant}" == "cli" ]]; then
            base_tag="${base_variant}-php${version}"
        fi
        echo "Creating Dockerfile for ${target_tag}"
        base_dockerfile="Dockerfile-${target_variant}"
        dockerfile_content=$(sed -e "s/PHP_VERSION/${version}/" "${base_dockerfile}")
        docker pull "${BASE_REGISTRY_REPO}:${base_tag}"
        new_image_tag="${TARGET_REGISTRY_REPO}:${target_tag}"
        echo -e "FROM ${BASE_REGISTRY_REPO}:${base_tag}\n${dockerfile_content}" | docker build -t "${new_image_tag}" -f - . 2>&1 > "docker_build_${base_tag}.log"
        result=$?
        if [[ "x${result}" != "x0" ]]; then
            echo 1>&2 "Failed building image for ${target_tag}"
            echo 1>&2 "Image kept on local disk for inspection"
        else
            echo "Building image for ${target_tag} succeeded"
            docker tag "${new_image_tag}" "${new_image_tag}-${DATE_TAG}"
            docker push "${new_image_tag}-${DATE_TAG}"
            docker push "${new_image_tag}"
            docker image rm "${new_image_tag}" "${new_image_tag}-${DATE_TAG}"
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
        docker image rm "${BASE_REGISTRY_REPO}:${base_tag}"
    done
done


# Build nginx image
echo "Creating Dockerfile for nginx:alpine"
docker build -t "yehuda/wp-nginx:${DATE_TAG}" nginx 2>&1 > "docker_build_nginx.log"
result=$?
if [[ "x${result}" != "x0" ]]; then
    echo 1>&2 "Failed building image for nginx:alpine"
    echo 1>&2 "Image kept on local disk for inspection"
else
    echo "Building image for nginx:alpine succeeded"
    docker tag "yehuda/wp-nginx:${DATE_TAG}" 'yehuda/wp-nginx:latest'
    docker push "yehuda/wp-nginx:${DATE_TAG}"
    docker push 'yehuda/wp-nginx:latest'
    docker image rm 'nginx:alpine' "yehuda/wp-nginx:${DATE_TAG}" 'yehuda/wp-nginx:latest'
fi
