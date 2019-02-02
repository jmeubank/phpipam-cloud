#!/bin/bash

bash --rcfile <(echo '. ~/.bashrc; source /root/venv-phpipam-eb/bin/activate') $*
