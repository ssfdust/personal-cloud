#!/bin/sh
set -e
BASEDIR=$(cd `dirname $0`;pwd)
ROCKY_VERSION=$(grep -oP "\d.\d" /etc/redhat-release)
source ${BASEDIR}/../config.sh

InstallRepos(){
    dnf install -y dnf-utils "https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-${ROCKY_VERSION}.rpm"
    dnf module reset -y php
    dnf module enable -y php:remi-8.0
}

InstallPhp(){
    dnf install -y php php-fpm mariadb-server php-intl php-imagick php-bcmath
}

ConfigurePhp() {
    crudini --set /etc/php-fpm.d/www.conf www user caddy
    crudini --set /etc/php-fpm.d/www.conf www group caddy
    crudini --set /etc/php-fpm.d/www.conf www listen.acl_users caddy
    crudini --set /etc/php.ini PHP memory_limit 512M
    chown -R root:caddy /var/lib/php/opcache/ /var/lib/php/session/ /var/lib/php/wsdlcache/
    systemctl enable php-fpm --now
}

ConfigureDB() {
    systemctl enable mariadb --now
    # Secure Installation With Mariadb
    expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$MYSQLPASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQLPASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
"
    # Disable 3006 port, more secure
    crudini --set /etc/my.cnf.d/mariadb-server.cnf mysqld skip_networking 1
    # high load with many concurrent transactions.
    crudini --set /etc/my.cnf.d/mariadb-server.cnf mysqld transaction_isolation READ-COMMITTED
    # Fix compatiable problem with mariadb
    # crudini --set /etc/my.cnf.d/mariadb-server.cnf mariadb-10.6 innodb_read_only_compressed OFF
}

InstallRepos
InstallPhp
ConfigurePhp
ConfigureDB
