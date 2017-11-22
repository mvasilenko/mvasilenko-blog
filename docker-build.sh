#!/bin/bash
export DOCKER_HUB_USERNAME="mvasilenko"
export APP="mvasilenko-blog"
export REPO_URL="https://github.com/${DOCKER_HUB_USERNAME}/${APP}.git"

if grep -q 'auths": {}' ~/.docker/config.json ; then
    docker login -u ${DOCKER_HUB_USERNAME}
fi
export TAG=$(git log -1 --format=%H)
export CACHEBUST=`git ls-remote ${REPO_URL} | grep refs/heads | cut -f 1` && \
echo $CACHEBUST
docker build -t ${DOCKER_HUB_USERNAME}/${APP}:${TAG} . --build-arg CACHEBUST=${CASHEBUST} # was=$(date +%s)
docker tag ${DOCKER_HUB_USERNAME}/${APP}:${TAG} ${DOCKER_HUB_USERNAME}/${APP}:latest
docker push ${DOCKER_HUB_USERNAME}/${APP}:latest
#docker rmi $(docker images --filter=reference="${DOCKER_HUB_USERNAME}/${HUGO_APP}" -q)
