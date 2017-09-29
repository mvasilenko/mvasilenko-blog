---
title: "Simple working example github circle ci docker aws ecr deploy"
date: 2017-09-29T17:53:31+03:00
tag: ["aws", "ecr", "docker", "github"]
categories: ["aws", "ci", "docker"]
topics: ["aws"]
banner: "banners/aws.png"
---


Simple example for CI pipeline - github commit, attached hook runs runs docker image build @ circle ci,
pushes docker image to the AWS ECR docker registry,
and deploys is to the AWS ECR cluster as a service.

https://github.com/mvasilenko/telegram-bot-kievradar

All magic happens at `.circleci/config.yml`



```
version: 2
jobs:
  build:
    docker:
      - image: circleci/python:3
    steps:
      - checkout
      - setup_remote_docker
      - run: |
          sudo pip install awscli
          sudo apt-get install jq
      # build and push Docker image
      - run: |
          docker build -t $CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1 .
      - deploy:
          name: Push application Docker image
          command: |

            CLUSTER="$CIRCLE_PROJECT_REPONAME"
            FAMILY="$CIRCLE_PROJECT_REPONAME"
            DOCKER_IMAGE=$CIRCLE_PROJECT_REPONAME
            TASK="$CIRCLE_PROJECT_REPONAME"
            SERVICE="$CIRCLE_PROJECT_REPONAME-service"

            eval "$(aws ecr get-login --region $AWS_DEFAULT_REGION | sed -e 's/-e none//g')"
            docker tag $CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1
            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1

            # create task for docker deploy
            # "portMappings": [
            #   {
            #     "containerPort": 3000,
            #     "hostPort": 80
            #   }
            # ],

            task_template='[
              {
                "name": "%s",
                "image": "%s.dkr.ecr.%s.amazonaws.com/%s:%s",
                "essential": true,
                "memoryReservation": 10,
                "environment" : [
                    { "name" : "TOKEN_BOT", "value" : "%s" }
                ]
              }
            ]'

            echo "$task_template"

            task_def=$(printf "$task_template" $TASK $AWS_ACCOUNT_ID $AWS_DEFAULT_REGION $DOCKER_IMAGE $CIRCLE_SHA1 $TOKEN_BOT)
            echo $task_def

            # Register task definition
            json=$(aws ecs register-task-definition --container-definitions "$task_def" --family "$FAMILY")

            # Grab revision # using regular bash and grep
            revision=$(echo "$json" | grep -o '"revision": [0-9]*' | grep -Eo '[0-9]+')

            # Deploy revision
            aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --task-definition "$TASK":"$revision"

```

YAML header, jobs level, we want to use python 3 docker image as a base,
checkout our source code from github, install docker client

```
version: 2
jobs:
  build:
    docker:
      - image: circleci/python:3
    steps:
      - checkout
      - setup_remote_docker
```

Install build and deploy requirements

```
      - run: |
          sudo pip install awscli
          sudo apt-get install jq

```

Build the docker image locally

```
      # build and push Docker image
      - run: |
          docker build -t $CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1 .
```


Login to AWS ECR docker repository, tag locally built image,
push it to the AWS ECR repository

```
      - deploy:
          name: Push application Docker image
          command: |

            CLUSTER="$CIRCLE_PROJECT_REPONAME"
            FAMILY="$CIRCLE_PROJECT_REPONAME"
            DOCKER_IMAGE=$CIRCLE_PROJECT_REPONAME
            TASK="$CIRCLE_PROJECT_REPONAME"
            SERVICE="$CIRCLE_PROJECT_REPONAME-service"

            eval "$(aws ecr get-login --region $AWS_DEFAULT_REGION | sed -e 's/-e none//g')"
            docker tag $CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1
            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$CIRCLE_PROJECT_REPONAME:$CIRCLE_SHA1
```


Describe the task template and fill it with our account and app data.

```
            task_template='[
              {
                "name": "%s",
                "image": "%s.dkr.ecr.%s.amazonaws.com/%s:%s",
                "essential": true,
                "memoryReservation": 10,
                "environment" : [
                    { "name" : "TOKEN_BOT", "value" : "%s" }
                ]
              }
            ]'

            echo "$task_template"

            task_def=$(printf "$task_template" $TASK $AWS_ACCOUNT_ID $AWS_DEFAULT_REGION $DOCKER_IMAGE $CIRCLE_SHA1 $TOKEN_BOT)
            echo $task_def
```


Register task defintion at AWS ECR service, and update our service revision by bumping revision number.

```
            # Register task definition
            json=$(aws ecs register-task-definition --container-definitions "$task_def" --family "$FAMILY")

            # Grab revision # using regular bash and grep
            revision=$(echo "$json" | grep -o '"revision": [0-9]*' | grep -Eo '[0-9]+')

            # Deploy revision
            aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --task-definition "$TASK":"$revision"
```

