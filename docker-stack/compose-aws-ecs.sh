#!/usr/bin/env bash

export $(grep -v '^#' ./aws-ecs.env | xargs -d '\n') && ecs-cli compose -f docker-compose.base.yml -f docker-compose.aws-ecs.yml -p secom-phpipam $*
