#!/bin/bash

export $(grep -v '^#' ./xms1.env | xargs -d '\n') && ./compose-xms1.sh exec dbnode mysql -u phpipam --password=$MYSQL_PASSWORD
