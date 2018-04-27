#!/bin/sh

set -e

ssh-keyscan -t rsa $TARGET_HOST > ~/.ssh/known_hosts
ssh -i /root/.ssh/private/id_rsa $LINUX_USER@$TARGET_HOST "mkdir -p $TARGET_PATH"
scp -i /root/.ssh/private/id_rsa /mysqldump/* $LINUX_USER@$TARGET_HOST:$TARGET_PATH/
