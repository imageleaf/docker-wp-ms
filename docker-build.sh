#!/bin/bash

if [ -z ${BASE_VERSION} ]; then
  echo >&2 Base version not specified
  exit 1
fi      

declare -A TARGET_TAG_VARIANT_MAP
TARGET_TAG_VARIANT_MAP=(
    ['cron']='cli'
    ['cli']='cli'
    ['fpm']='fpm'
    ['fpm-alpine']='fpm-alpine'
)

BASE_REGISTRY_REPO='wordpress'
TARGET_REGISTRY_REPO='yehuda/wordpress'
BUILD_NGINX=yes
if [ -z ${IMAGE_TAG} ]; then
  IMAGE_TAG=`date +%Y%m%d`
  BUILD_NGINX=no
fi

# Build wordpress images
version=${BASE_VERSION}
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
  set -x
  echo -e "FROM ${BASE_REGISTRY_REPO}:${base_tag}\n${dockerfile_content}" | docker build -t "${new_image_tag}" -f - . 2>&1 > "docker_build_${base_tag}.log"
  set +x
  result=$?
  if [[ "x${result}" != "x0" ]]; then
    echo 1>&2 "Failed building image for ${target_tag}"
    echo 1>&2 "Image kept on local disk for inspection"
  else
    echo "Building image for ${target_tag} succeeded"
    docker tag "${new_image_tag}" "${new_image_tag}-${IMAGE_TAG}"
    docker push "${new_image_tag}-${IMAGE_TAG}"
    docker push "${new_image_tag}"
  fi
done

if [ "${BUILD_NGINX}" == "no" ]; then
  exit
fi

# Build nginx image
echo "Creating Dockerfile for nginx:alpine"
docker build \
  -t "yehuda/wp-nginx:${IMAGE_TAG}" \
  -t "yehuda/wp-nginx:latest" \
  nginx 2>&1 > "docker_build_nginx.log"
result=$?
if [[ "x${result}" != "x0" ]]; then
    echo 1>&2 "Failed building image for nginx:alpine"
    echo 1>&2 "Image kept on local disk for inspection"
else
    echo "Building image for nginx:alpine succeeded"
    docker push "yehuda/wp-nginx:${IMAGE_TAG}"
    docker push 'yehuda/wp-nginx:latest'
fi
