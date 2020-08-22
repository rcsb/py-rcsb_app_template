#!/usr/bin/env bash
#
REGISTRY_USER=${REGISTRY_USER}
#
IMAGE_NAME=${IMAGE_NAME:-"py-rcsb_app_template"}
TAG_TEST=${TAG_TEST:-"unittest"}
TAG_BASE=${TAG_BASE:-"test"}
PY_MODULE=${PY_MODULE:-"template"}
#
VER=`grep '__version__' rcsb/app/${PY_MODULE}/__init__.py | awk '{print $3}' | tr -d '"'`
#
docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
             --build-arg VCS_REF=`git rev-parse --short HEAD` \
             --build-arg VERSION=$VER \
             --tag ${REGISTRY_USER}/${IMAGE_NAME}:${TAG_TEST} \
             --file ./Dockerfile.${TAG_BASE} .

#
docker rm -f ${IMAGE_NAME}
echo "Begin running unittests on image ${IMAGE_NAME}"
docker run --name ${IMAGE_NAME} ${REGISTRY_USER}/${IMAGE_NAME}:${TAG_TEST} tox >& /dev/null || {
    echo "Unittests failing for ${IMAGE_NAME} ---- return code: $?"
    docker logs ${IMAGE_NAME} >& ${IMAGE_NAME}-unittest.log
    docker rmi -f ${IMAGE_NAME}
    docker rm -f ${IMAGE_NAME}
    exit 1
}
echo "Unit Tests succeed for ${IMAGE_NAME} ---- return code: $?"
#
docker rmi -f ${IMAGE_NAME}
docker rmi -f ${IMAGE_NAME}:${TAG_TEST}
docker rm -f ${IMAGE_NAME}
#
docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
             --build-arg VCS_REF=`git rev-parse --short HEAD` \
             --build-arg VERSION=$VER \
             --tag ${REGISTRY_USER}/${IMAGE_NAME}:${TAG_BASE} \
             --tag ${REGISTRY_USER}/${IMAGE_NAME}:${VER} \
             --file ./Dockerfile  .
#
docker image ls
#
#docker push  ${REGISTRY_USER}/${IMAGE_NAME}
