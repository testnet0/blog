#!/bin/bash
current_dir=$(pwd)

echo "================================"
echo "开始检测环境"

# 检测maven环境是否存在
if command -v mvn >/dev/null 2>&1 ; then
echo "Maven is installed"
else
echo "mvn命令不存在，请先安装Maven"
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

# 配置Mysql密码
echo "请输入Mysql密码："
read password
if [ -z "$password" ]; then
  echo "Mysql密码输入错误"
  exit 1
fi
sed -i "s/<mysql_password>/$password/g" $current_dir"/blog-springboot/src/main/resources/application.yml"
sed -i "s/<mysql_password>/$password/g" $current_dir"/docker-compose.yaml"

# 配置域名信息

echo "请输入你自己的域名："
read domain
if [ -z "$domain" ]; then
  echo "域名输入错误"
  exit 1
fi
sed -i "s/<domain>/$domain/g" $current_dir"/blog-springboot/src/main/resources/application.yml"
sed -i "s/<domain>/$domain/g" $current_dir"/nginx.conf"


# 配置发送邮件服务器的地址

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

echo "================================"
echo "开始编译代码"
# 编译后端代码
cd $current_dir + "/blog-springboot"
mvn clean install
if [ $? -eq 0 ]; then
echo "Build Successful"
else
echo "Maveb Build Failed"
fi

# 编译前端代码
cd $current_dir + "/blog-vue/admin"
npm install && npm run build
cd $current_dir + "/blog-vue/blog"
npm install && npm run build
echo "================================"
echo "请去域名控制台，添加域名解析A记录,指向服务器的公网IP："
echo $domain
echo "ws."$domain
echo "admin."$domain
echo "upload."$domain
echo "================================"


docker-compose up