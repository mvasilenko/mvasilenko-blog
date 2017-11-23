FROM nginx:alpine

ENV HUGO_VERSION="0.31"
ENV GITHUB_USERNAME="mvasilenko"
ENV DOCKER_IMAGE_NAME="mvasilenko-blog"

USER root

RUN apk add --update \
    wget \
    git \
    ca-certificates

RUN wget --quiet https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mkdir -p hugo_${HUGO_VERSION}_linux_amd64 && \
    tar -xf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C hugo_${HUGO_VERSION}_linux_amd64/ && \
    chmod +x hugo_${HUGO_VERSION}_linux_amd64/hugo && \
    mv hugo_${HUGO_VERSION}_linux_amd64/hugo /usr/local/bin/hugo && \
    rm -rf hugo_${HUGO_VERSION}_linux_amd64/ hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

ARG CACHEBUST=1
RUN git clone https://github.com/${GITHUB_USERNAME}/${DOCKER_IMAGE_NAME}.git

RUN hugo -s ${DOCKER_IMAGE_NAME} -d /usr/share/nginx/html
RUN ls -la /usr/share/nginx/html
# --uglyURLs

CMD nginx -g "daemon off;"
