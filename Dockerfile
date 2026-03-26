FROM centos:7.9.2009
LABEL maintainer="xyh5"
LABEL description="梦幻西游H5游戏服务器"

# ------------ 一键修复 CentOS7 失效源（解决 mirrorlist 报错）------------
RUN sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
    yum clean all && yum makecache

# 下面是你原来的安装命令，无需修改
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
    epel-release \
    supervisor && \
    yum clean all

# 安装MySQL 5.7
# 终极修复：MySQL 5.7 安装（无语法错误版）
RUN yum install -y ca-certificates openssl && \
    update-ca-trust && \
    wget -O mysql57.rpm http://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm && \
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 && \
    rpm -Uvh mysql57.rpm --nodeps --force && \
    sed -i 's|gpgcheck=1|gpgcheck=0|g' /etc/yum.repos.d/mysql-community.repo && \
    yum install -y mysql-community-server --skip-broken --nogpgcheck && \
    rm -f mysql57.rpm && yum clean all

# 安装PHP 7.4 (兼容旧版PHP代码)
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php74 && \
    yum install -y php php-fpm php-mysqlnd php-gd php-mbstring php-xml php-json && \
    yum clean all

# ====================== 彻底无下载：YUM 一键安装 Lua + Luarocks ======================
RUN yum install -y epel-release && \
    yum install -y lua lua-devel luarocks && \
    luarocks install luasocket && \
    yum clean all

# 安装 luasocket
RUN /usr/local/bin/luarocks install luasocket --force

# 创建目录
RUN mkdir -p /data/mysql /data/logs /home/server /www/wwwroot/xy

# 复制游戏服务端
COPY server/ /home/server/
COPY www/ /www/wwwroot/xy/

# 复制数据库初始化脚本
COPY sql/ /tmp/sql/

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
