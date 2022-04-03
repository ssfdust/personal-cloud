#!/bin/sh

InstallCaddy(){
    dnf install -y 'dnf-command(copr)'
    dnf copr enable -y @caddy/caddy
    dnf install -y caddy
}

Initilize() {
    install -o caddy -g caddy -d /var/log/caddy
    rpm -ivh /usr/local/src/rpms/caddy_selinux-*.rpm
    restorecon -R /var/log/caddy
    semanage port -a -t http_port_t -p tcp 2019
    systemctl enable caddy --now
}

InstallCaddy
Initilize
