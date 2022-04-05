#!/bin/sh

InstallCaddy(){
    dnf install -y 'dnf-command(copr)'
    dnf copr enable -y @caddy/caddy
    dnf install -y caddy
}

Initilize() {
    install -o caddy -g caddy -d /var/log/caddy
    dnf install -y /usr/local/src/rpms/caddy_selinux-*.rpm
    restorecon -R /var/log/caddy
}

ConfigureCaddy() {
    install -d /etc/caddy/sites-enabled.d/
    mv /etc/caddy/Caddyfile /etc/caddy/sites-enabled.d/index.conf
    echo "import /etc/caddy/sites-enabled.d/*.conf" > /etc/caddy/Caddyfile
    restorecon -R /etc/caddy
    chcon -u system_u -R /etc/caddy
    systemctl enable caddy --now
}

InstallCaddy
Initilize
ConfigureCaddy
