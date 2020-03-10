# apiadmin-dnmp

- [ApiAdmin-DNMP (ApiAdmin + Docker + Nginx + MySQL + PHP7 + Redis)](dnmp/README.md)

> 此项目为快速搭建ApiAdmin，目前在Mac下测通

### 系统需求

- [docker](https://www.docker.com/)
- [nodejs](http://nodejs.cn/)

### 安装说明

1. `clone`项目

```
git clone https://gitee.com/bstdn/apiadmin-dnmp
```

2. 如果不是`root`用户，还需将当前用户加入`docker`用户组

```
sudo gpasswd -a ${USER} docker
```

3. 进入 `apiadmin-dnmp`，目录运行 `install.sh`，根据提示进行安装

```
cd apiadmin-dnmp
./install.sh
```

```
# 运行 `isntall.sh` 展示如下
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
  6）查看账号密码
  7）克隆ApiAdmin-WEB项目，npm install（未安装npm则退出）
  8）配置nginx（需手动修改/etc/hosts）
  9）配置cache
  10）配置Api地址
  11）运行ApiAdmin-WEB项目

请输入希望执行的序号，可多选，空格键分开
直接回车则全选（不包括0），Ctrl-C 退出脚本：
```

### 相关技术栈

- [dnmp](https://gitee.com/bstdn/dockerfile/tree/master/dnmp)
- [ApiAdmin](https://gitee.com/apiadmin/ApiAdmin)
- [ApiAdmin-WEB](https://gitee.com/apiadmin/ApiAdmin-WEB)

## 赞赏

**请作者喝杯咖啡吧！(微信号/QQ号：99808359)**

<img width="236" alt="微信扫一扫" src="https://images.gitee.com/uploads/images/2019/1122/203838_862f04ff_1185106.jpeg">

Copyright (c) 2020-present, bstdn
