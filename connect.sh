#!/bin/bash

ssh -p 22 root@192.168.12.165 -t "cd /root/phpipam-eb; exec ./getstarted.sh"
