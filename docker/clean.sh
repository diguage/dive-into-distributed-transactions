#!/usr/bin/env bash
#
# 清理环境
# D瓜哥 · https://www.diguage.com
#

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker compose down -v

docker image rm -f order/mysql:8.4

docker image rm -f storage/mysql:8.4

docker image rm -f account/mysql:8.4

docker image rm -f nacos/mysql:8.4

rm -rf $BASEDIR/data/mysql/*
