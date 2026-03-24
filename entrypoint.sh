#!/bin/bash

set -e

echo "=========================================="
echo "  梦幻西游H5游戏服务器启动中..."
echo "=========================================="

# 修改IP
sed -i "s/39.105.134.68/${SERVER_IP}/g" /www/wwwroot/xy/cdn/*.js
sed -i "s/39.105.134.68/${SERVER_IP}/g" /www/wwwroot/xy/cdn/*.html
sed -i "s/39.105.134.68/${SERVER_IP}/g" /www/wwwroot/xy/cdn/*.php
sed -i "s/39.105.134.68/${SERVER_IP}/g" /www/wwwroot/xy/cdn/*.json

# 修改数据库密码
sed -i "s/echeverra/${MYSQL_ROOT_PASSWORD}/g" /home/server/*/config.xml
sed -i "s/echeverra/${MYSQL_ROOT_PASSWORD}/g" /www/wwwroot/xy/gm/config.php
sed -i "s/echeverra/${MYSQL_ROOT_PASSWORD}/g" /www/wwwroot/xy/cb.php

# 初始化MySQL
echo "初始化MySQL..."
mysqld --initialize-insecure --user=mysql --datadir=/data/mysql 2>/dev/null || true
chown -R mysql:mysql /data/mysql

# 启动MySQL
echo "启动MySQL..."
mysqld --user=mysql --datadir=/data/mysql &
MYSQL_PID=$!

# 等待MySQL启动
for i in {1..30}; do
    if mysql -u root -e "SELECT 1" &>/dev/null; then
        echo "MySQL启动成功"
        break
    fi
    sleep 1
done

# 创建数据库并导入
echo "创建数据库..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS account DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS chargeserver DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS gameserver DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS gmserver DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS oaglobal DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS operationanalysisserver DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS worldserver DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 导入SQL
echo "导入数据库..."
mysql -u root -p${MYSQL_ROOT_PASSWORD} account < /tmp/sql/account.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} chargeserver < /tmp/sql/chargeserver.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} gameserver < /tmp/sql/gameserver.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} gmserver < /tmp/sql/gmserver.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} oaglobal < /tmp/sql/oaglobal.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} operationanalysisserver < /tmp/sql/operationanalysisserver.sql 2>/dev/null || true
mysql -u root -p${MYSQL_ROOT_PASSWORD} worldserver < /tmp/sql/worldserver.sql 2>/dev/null || true

# 启动Nginx
echo "启动Nginx..."
nginx

# 启动PHP-FPM
echo "启动PHP-FPM..."
php-fpm

# 设置信号处理
trap "killall mysqld nginx php-fpm; exit" SIGTERM SIGINT

echo "=========================================="
echo "  游戏服务器启动完成!"
echo "  游戏地址: http://${SERVER_IP}/cdn/"
echo "  GM工具: http://${SERVER_IP}/gm/"
echo "=========================================="

# 等待子进程
wait
