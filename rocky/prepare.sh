#!/bin/sh

set -e
BASEDIR=$(cd `dirname $0`;pwd)

InitRepo () {
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-AppStream.repo \
    /etc/yum.repos.d/Rocky-BaseOS.repo \
    /etc/yum.repos.d/Rocky-Extras.repo \
    /etc/yum.repos.d/Rocky-PowerTools.repo
    dnf makecache
    dnf update -y
}

InitEpel () {
    dnf install -y epel-release
    sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
         -e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
         -i.bak \
         /etc/yum.repos.d/epel.repo \
         /etc/yum.repos.d/epel-modular.repo
    dnf makecache
}

CopySELinuxRPMS () {
    mkdir /usr/local/src/rpms
    cp -r selinux/releases/*.rpm /usr/local/src/rpms
}

Main () {
    InitRepo
    InitEpel
}

Main
