#!/bin/sh

LAGOON_API_TOKEN=$(ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 32222 -t lagoon@ssh.lagoon.amazeeio.cloud token 2> /dev/null | tr -d '\n\r')
LAGOON_API_TOKEN=$LAGOON_API_TOKEN GITHUB_API_TOKEN=$GITHUB_API_TOKEN ./lagoon-envs-cleanup.sh -g rasch -p $PROJECTS
