#!/bin/sh

set -e
BASEDIR=$(cd `dirname $0`;pwd)

InitRepo () {
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-AppStream.repo \
    /etc/yum.repos.d/Rocky-BaseOS.repo \
    /etc/yum.repos.d/Rocky-Extras.repo \
    /etc/yum.repos.d/Rocky-PowerTools.repo
    dnf makecache
    dnf update -y
}

UpdateKernel () {
    dnf install -y https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el8/x86_64/RPMS/elrepo-release-8.2-1.el8.elrepo.noarch.rpm
    dnf install --enablerepo=elrepo-kernel -y kernel-ml kernel-ml-tools --allowerasing
    install -m750 "${BASEDIR}/purge_old_kernels.sh" /usr/local/bin
    install -m644 "${BASEDIR}/purge_old_kernels.service" /etc/systemd/system
    systemctl enable purge_old_kernels
}

InitEpel () {
    dnf install -y epel-release
    sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/|g' \
         -e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/|g' \
         -i.bak \
         /etc/yum.repos.d/epel.repo \
         /etc/yum.repos.d/epel-modular.repo
    dnf makecache
}

InstallPackages () {
    dnf install -y crudini expect policycoreutils-python-utils
}


InitPackages () {
    install -d /usr/local/src/rpms
    cp packages/* /usr/local/src/rpms
}

Main () {
    InitRepo
    InitEpel
    UpdateKernel
    InstallPackages
    InitPackages
}

Main
