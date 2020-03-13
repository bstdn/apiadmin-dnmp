#!/bin/bash
#-------------------------------注意------------------------------#

#建议不要单独运行此脚本。
#请使用上层目录的install.sh进行引导。

#-------------------------------！！-----------------------------#

ROOT=`pwd`

if [ ! -f dnmp/.env ]; then
  cp maintain/env.apiadmin dnmp/.env
fi

if [ ! -f dnmp/docker-compose.yml ]; then
  cp maintain/docker-compose.apiadmin.yml dnmp/docker-compose.yml
fi

cd dnmp
docker-compose up -d
if [ "$?" != "0" ]; then
  echo "未启动Docker"
  exit 1
fi
