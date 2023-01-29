#!/bin/bash
current_dir=$(pwd)

function rm_docker {
  docker stop web
  docker image rm web:1.0 -f 
  docker build -t web:1.0 .
  docker start web
}
#检测环境
function check_environment {
echo "================================"
echo "开始检测环境"

# 检测maven环境是否存在
if command -v mvn >/dev/null 2>&1 ; then
echo "Maven is installed"
else
echo "mvn命令不存在，请先安装Maven"
exit
fi

# 检测nodejs环境是否存在
if command -v npm >/dev/null 2>&1 ; then
echo "npm is installed"
else
echo "npm命令不存在，请先安装nodejs！"
exit
fi

# 检测docker-compose环境是否存在
if command -v docker-compose >/dev/null 2>&1 ; then
echo "docker-compose is installed"
else
echo "docker-compose命令不存在，请先安装docker-compose！"
exit
fi
}

# 配置Mysql密码
function configure_mysql {
echo "请输入Mysql密码："
read password
if [ -z "$password" ]; then
  echo "Mysql密码输入错误"
  exit 1
fi
sed -i "s/<mysql_password>/$password/g" $current_dir"/blog-springboot/src/main/resources/application.yml"
sed -i "s/<mysql_password>/$password/g" $current_dir"/docker-compose.yaml"
}


# 配置域名信息
function configure_host {
echo "请输入你自己的域名："
read domain
if [ -z "$domain" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<domain>/$domain/g" $current_dir"/blog-springboot/src/main/resources/application.yml"
sed -i "s/<domain>/$domain/g" $current_dir"/nginx.conf"

}
# 配置发送邮件服务器的地址

function configure_mail {
echo "请输入发信邮箱服务器，如stmp.xx.xx："
read mail_host
if [ -z "$mail_host" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<mail_host>/$mail_host/g" $current_dir"/blog-springboot/src/main/resources/application.yml"

echo "请输入发信邮箱用户名"
read mail_username
if [ -z "$mail_username" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<mail_username>/$mail_username/g" $current_dir"/blog-springboot/src/main/resources/application.yml"

echo "请输入发信邮箱密码："
read mail_password
if [ -z "$mail_password" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<mail_password>/$mail_password/g" $current_dir"/blog-springboot/src/main/resources/application.yml"

echo "请输入发信邮箱端口："
read mail_port
if [ -z "$mail_port" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<mail_port>/$mail_port/g" $current_dir"/blog-springboot/src/main/resources/application.yml"
}

# 编译后端代码

function build_backend {
echo "================================"
echo "开始编译后端代码"
cd $current_dir"/blog-springboot"
mvn clean install
if [ $? -eq 0 ]; then
echo "Build Successful"
else
echo "Maveb Build Failed"
fi
}

# 编译前端代码
function build_front {
echo "================================"
echo "开始编译前端代码"
cd $current_dir"/blog-vue/admin"
npm install && npm run build
cd $current_dir"/blog-vue/blog"
npm install && npm run build
}

function echo_end {
echo "================================"
echo "编译完成请去域名控制台，添加域名解析A记录,指向服务器的公网IP："
echo $domain "====>IP"
echo "ws."$domain "====>IP"
echo "admin."$domain "====>IP"
echo "upload."$domain "====>IP"
echo "================================"
}

if ls -d $current_dir/data &> /dev/null; then
  echo "检测到已经安装，进入更新模式"
  rm_docker
  build_backend
  build_front
else
  echo "检测到未安装，进入配置模式"
  check_environment
  configure_mysql
  configure_host
  configure_mail
  build_backend
  build_front
  echo_end
fi

docker-compose up
