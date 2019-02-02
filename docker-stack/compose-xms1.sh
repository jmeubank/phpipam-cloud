#!/usr/bin/env bash

export $(grep -v '^#' ./xms1.env | xargs -d '\n') && docker-compose -f docker-compose.base.yml -f docker-compose.xms1.yml $*
