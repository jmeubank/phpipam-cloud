#!/bin/bash

docker build -t secom-phpipam:phpipam . || docker container prune -f
