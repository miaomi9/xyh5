FROM centos:7

LABEL maintainer="xyh5"
LABEL description="梦幻西游H5游戏服务器"

# 安装基础软件
RUN yum install -y \
    wget \
    gcc \
    gcc-c++ \
    make \
    glibc-devel \
    readline-devel \
    ncurses-devel \
    openssl-devel \
    libxml2 \
    libxml2-devel \
    libxslt \
    libxslt-devel \
    nginx \
   Supervisor

# 安装MySQL 5.6
RUN wget https://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && \
    rpm -ivh mysql-community-release-el7-5.noarch.rpm && \
    yum install -y mysql-community-server && \
    yum clean all

# 安装PHP 5.6
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh epel-release-latest-7.noarch.rpm && \
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php56 && \
    yum install -y php php-fpm php-mysql php-gd php-mbstring php-xml && \
    yum clean all

# 安装Lua 5.1
WORKDIR /tmp
RUN wget http://www.lua.org/ftp/lua-5.1.5.tar.gz && \
    tar zxf lua-5.1.5.tar.gz && \
    cd lua-5.1.5 && \
    make linux && \
    make install && \
    cd /tmp && rm -rf lua-5.1.5*

# 安装luarocks
RUN wget https://keplerproject.github.io/luarocks/releases/luarocks-3.0.4.tar.gz && \
    tar zxf luarocks-3.0.4.tar.gz && \
    cd luarocks-3.0.4 && \
    ./configure --prefix=/usr/local --with-lua=/usr/local --with-lua-include=/usr/local/include && \
    make && make install && \
    cd /tmp && rm -rf luarocks-3.0.4*

# 安装luasocket
RUN /usr/local/bin/luarocks install luasocket

# 创建目录
RUN mkdir -p /data/mysql /data/logs /home/server /www/wwwroot/xy

# 复制游戏服务端
COPY server/ /home/server/
COPY www/ /www/wwwroot/xy/

# 复制数据库初始化脚本
COPY init.sql /tmp/init.sql

# 复制Nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 复制supervisor配置
COPY supervisord.conf /etc/supervisord.conf

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 设置权限
RUN chmod -R 777 /home/server

# 开放端口
EXPOSE 80 3306 8001 8002 8004 10001 11001 12001

ENTRYPOINT ["/entrypoint.sh"]
