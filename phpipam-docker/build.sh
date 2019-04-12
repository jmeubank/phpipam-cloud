#!/bin/bash

docker build -t 146686453577.dkr.ecr.us-east-2.amazonaws.com/secom-phpipam:phpipam . || docker container prune -f
