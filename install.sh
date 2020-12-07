#!/bin/bash

ROOT=`pwd`
I_WANT_IT=""

#提示信息
cat <<EOF >&1
！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
！！！！！！！！！！！注意！！！！！！！！！！CAUTION ！！！！！！！！！！！！！！！
！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
此脚本包含以下部分（建议启动Docker服务后执行一次1，以减少错误几率）：
  0）停用DNMP服务
  1）启动DNMP服务
  2）创建数据库，如果数据库已存在，则忽略
  3）克隆ApiAdmin项目，composer install
  4）检测环境以及配置数据库
  5）数据库迁移
  6）构建后端路由（ApiAdmin5.x）
  7）查看账号密码
  8）克隆ApiAdmin-WEB项目，npm install（未安装npm则退出）
  9）配置nginx（需手动修改/etc/hosts）
  10）配置cache
  11）配置Api地址
  12）运行ApiAdmin-WEB项目
  13）克隆ApiAdmin-Element项目，npm install（未安装npm则退出）
  14）运行ApiAdmin-Element项目
EOF

echo
echo "请输入希望执行的序号，可多选，空格键分开"
read -p "直接回车则全选（不包括0），Ctrl-C 退出脚本：" I_WANT_IT
if [ "$I_WANT_IT" == "" ]; then
  I_WANT_IT="1 2 3 4 5 6 7 8 9 10 11 12 13 14"
fi

for i in $I_WANT_IT
do
case $i in
  0)
    echo
    echo "[0-1]停用DNMP服务"
    cd ${ROOT}/dnmp
    docker-compose stop
    echo "[0-1]执行完毕"
    ;;
  1)
    echo
    echo "[1-1]启动DNMP服务"
    bash maintain/docker.sh
    echo "[1-1]执行完毕"
    ;;
  2)
    echo
    echo "[2-1]创建数据库，如果数据库已存在，则忽略"
    source ${ROOT}/dnmp/.env
    docker exec -it mysql5 /bin/bash -c 'mysql -uroot -p'${MYSQL5_ROOT_PASSWORD}' -e "CREATE DATABASE IF NOT EXISTS '${APIADMIN_DATABASE}' DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"'
    if [ $? -ne 0 ]; then
      echo "启动DNMP服务后再试"
      exit 1
    fi
    echo "[2-1]执行完毕"
    ;;
  3)
    echo
    echo "[3-1]克隆ApiAdmin项目"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ ! -d ApiAdmin ]; then
      git clone ${APIADMIN_GIT_URL}
    fi
    echo "[3-1]执行完毕"
    echo
    echo "[3-2]执行 composer install"
    if [ ! -d ApiAdmin/vendor ]; then
      composer install
      docker exec -it php /bin/sh -c 'cd /www/ApiAdmin;composer install'
      if [ $? -ne 0 ]; then
        echo "启动DNMP服务后再试"
        exit 1
      fi
    fi
    echo "[3-2]执行完毕"
    ;;
  4)
    echo
    echo "[4-1]检测环境以及配置数据库"
    source ${ROOT}/dnmp/.env
    docker exec -it php /bin/sh -c 'cd /www/ApiAdmin;php think apiadmin:install --db mysql://root:'${MYSQL5_ROOT_PASSWORD}'@mysql5:3306/'${APIADMIN_DATABASE}'#utf8mb4'
    if [ $? -ne 0 ]; then
      echo "启动DNMP服务后再试"
      exit 1
    fi
    echo "[4-1]执行完毕"
    ;;
  5)
    echo
    echo "[5-1]数据库迁移"
    docker exec -it php /bin/sh -c 'cd /www/ApiAdmin;php think migrate:run'
    if [ $? -ne 0 ]; then
      echo "启动DNMP服务后再试"
      exit 1
    fi
    echo "[5-1]执行完毕"
    ;;
  6)
    echo
    echo "[6-1]构建后端路由（ApiAdmin5.x）"
    docker exec -it php /bin/sh -c 'cd /www/ApiAdmin;php think apiadmin:adminRouter'
    if [ $? -ne 0 ]; then
      echo "启动DNMP服务后再试"
      exit 1
    fi
    echo "[6-1]执行完毕"
    ;;
  7)
    echo
    echo "[7-1]查看账号密码"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ -f ApiAdmin/application/install/lock.ini ]; then
      cat ApiAdmin/application/install/lock.ini
    elif [ -f ApiAdmin/install/lock.ini ]; then
      cat ApiAdmin/install/lock.ini
    fi
    echo "[7-1]执行完毕"
    ;;
  8)
    echo
    echo "[8-1]检测npm"
    npm -v 2>/dev/null 1>/dev/null
    if [ $? -ne 0 ]; then
      echo "npm 尚未安装，请安装后再试"
      exit 1
    fi
    echo "[8-1]执行完毕"
    echo
    echo "[8-2]克隆ApiAdmin-WEB项目"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ ! -d ApiAdmin-WEB ]; then
      git clone ${APIADMIN_WEB_GIT_URL}
    fi
    echo "[8-2]执行完毕"
    echo
    echo "[8-3]执行 npm install"
    if [ ! -d ApiAdmin-WEB/node_modules ]; then
      cd ApiAdmin-WEB
      npm install --registry=https://registry.npm.taobao.org
    fi
    echo "[8-3]执行完毕"
    ;;
  8)
    echo
    echo "[8-1]配置nginx"
    source ${ROOT}/dnmp/.env
    cd ${ROOT}
    if [ ! -f dnmp/services/nginx/conf.d/apiadmin.conf ]; then
      cp maintain/apiadmin.conf dnmp/services/nginx/conf.d/
      docker exec -it nginx /bin/sh -c 'sed -i "s#{server_name}#'${APIADMIN_SERVER_NAME}'#" /etc/nginx/conf.d/apiadmin.conf'
      docker exec -it nginx nginx -s reload
      if [ $? -ne 0 ]; then
        echo "启动DNMP服务后再试"
        exit 1
      fi
    fi
    echo "手动修改/etc/hosts"
    echo "添加一行"
    echo "127.0.0.1 ${APIADMIN_SERVER_NAME}"
    echo "[8-1]执行完毕"
    ;;
  10)
    echo
    echo "[10-1]配置cache"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    docker exec -it php /bin/sh -c 'sed -i "s#127.0.0.1#redis#" /www/ApiAdmin/config/cache.php'
    echo "[10-1]执行完毕"
    ;;
  11)
    echo
    echo "[11-1]配置Api地址"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    docker exec -it php /bin/sh -c 'sed -i "s#https://api.apiadmin.org/#http://'${APIADMIN_SERVER_NAME}'/#" /www/ApiAdmin-WEB/src/config/index.js'
    echo "[11-1]执行完毕"
    ;;
  12)
    echo
    echo "[12-1]运行ApiAdmin-WEB项目"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ ! -d ApiAdmin-WEB ]; then
      echo "ApiAdmin-WEB 不存在"
      exit 1
    fi
    cd ApiAdmin-WEB
    npm run dev
    echo "[12-1]执行完毕"
    ;;
  13)
    echo
    echo "[13-1]检测npm"
    npm -v 2>/dev/null 1>/dev/null
    if [ $? -ne 0 ]; then
      echo "npm 尚未安装，请安装后再试"
      exit 1
    fi
    echo "[13-1]执行完毕"
    echo
    echo "[13-2]克隆ApiAdmin-Element项目"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ ! -d ApiAdmin-Element ]; then
      git clone ${APIADMIN_ELEMENT_GIT_URL}
    fi
    echo "[13-2]执行完毕"
    echo
    echo "[13-3]执行 npm install"
    if [ ! -d ApiAdmin-Element/node_modules ]; then
      cd ApiAdmin-Element
      npm install --registry=https://registry.npm.taobao.org
    fi
    echo "[13-3]执行完毕"
    ;;
  14)
    echo
    echo "[14-1]运行ApiAdmin-Element项目"
    cd ${ROOT}/dnmp && source .env && cd ${SOURCE_DIR}
    if [ ! -d ApiAdmin-Element ]; then
      echo "ApiAdmin-Element 不存在"
      exit 1
    fi
    cd ApiAdmin-Element
    npm run dev
    echo "[14-1]执行完毕"
    ;;
esac
done
