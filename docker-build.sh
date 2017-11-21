#!/usr/bin/env bash
export DOCKER_HUB_USERNAME="mvasilenko"
export APP="mvasilenko-blog"
if grep -q 'auths": {}' ~/.docker/config.json ; then
    docker login -u ${DOCKER_HUB_USERNAME}
fi
export TAG=$(git log -1 --format=%H)
docker build -t ${DOCKER_HUB_USERNAME}/${APP}:${TAG} .
docker tag ${DOCKER_HUB_USERNAME}/${APP}:${TAG} ${DOCKER_HUB_USERNAME}/${APP}:latest
docker push ${DOCKER_HUB_USERNAME}/${APP}:latest
#docker rmi $(docker images --filter=reference="${DOCKER_HUB_USERNAME}/${HUGO_APP}" -q)
