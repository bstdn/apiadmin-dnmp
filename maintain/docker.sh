#!/bin/bash
#-------------------------------注意------------------------------#

#建议不要单独运行此脚本。
#请使用上层目录的install.sh进行引导。

#-------------------------------！！-----------------------------#

ROOT=`pwd`

cd dnmp

if [ ! -f .env ]; then
  cp env.apiadmin .env
fi

if [ ! -f docker-compose.yml ]; then
  cp docker-compose.apiadmin.yml docker-compose.yml
fi

docker-compose up -d
if [ "$?" != "0" ]; then
  echo "未启动Docker"
  exit 1
fi
