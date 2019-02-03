#!/usr/bin/env bash

export $(grep -v '^#' ./ch1.env | xargs -d '\n') && \
    docker-compose -H "ssh://deploy@208.123.128.43" -f docker-compose.base.yml -f docker-compose.ch1.yml $*
