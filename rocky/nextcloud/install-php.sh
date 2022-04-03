#!/bin/sh
set -e
BASEDIR=$(cd `dirname $0`;pwd)
ROCKY_VERSION=$(grep -oP "\d.\d" /etc/redhat-release)

InstallRepos(){
    dnf install -y dnf-utils "https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-${ROCKY_VERSION}.rpm"
    dnf module reset -y php
    dnf module enable -y php:remi-8.1
}

InstallRepos
