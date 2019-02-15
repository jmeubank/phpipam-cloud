#!/bin/bash

# this script works on the local dev machine
# if you run it locally, then run compose-ch1.sh, the credentials
# will be passed through transparently to ContainerHost1

$(aws ecr get-login --no-include-email)
