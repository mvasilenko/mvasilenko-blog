#!/usr/bin/env bash
export DOCKER_HUB_USERNAME="mvasilenko"
export HUGO_APP="mvasilenko-blog"
docker login -u ${DOCKER_HUB_USERNAME}
export HUGO_APP_TAG="1.0"
docker build -t ${DOCKER_HUB_USERNAME}/${HUGO_APP}:${HUGO_APP_TAG} .
docker push ${DOCKER_HUB_USERNAME}/${HUGO_APP}:${HUGO_APP_TAG}
#docker rmi $(docker images --filter=reference="${DOCKER_HUB_USERNAME}/${HUGO_APP}" -q)
