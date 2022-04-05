#!/bin/sh
set -e
BASEDIR=$(cd `dirname $0`;pwd)
source "${BASEDIR}/../config.sh"

InstallRPM (){
    dnf install -y /usr/local/src/rpms/nextcloud-*.rpm
    dnf install -y /usr/local/src/rpms/nextcloud_selinux*.rpm
}

ConfigureCaddy () {
    install -m644 "${BASEDIR}/nextcloud.conf" /etc/caddy/sites-enabled.d/nextcloud.conf
    sed -i "s/NEXTCLOUDDOMAIN/${NEXTCLOUDDOMAIN}/" /etc/caddy/sites-enabled.d/nextcloud.conf
    restorecon -R /etc/caddy
    systemctl restart caddy
}

InitNextcloud () {
    pushd /srv/www/nextcloud
    sudo -u caddy php occ maintenance:install \
        --database "mysql" \
        --database-name "nextcloud" \
        --database-user "root" \
        --database-pass "${MYSQLPASSWORD}" \
        --admin-user "${NEXTCLOUDUSER}" \
        --admin-email "${NEXTCLOUDEMAIL}" \
        --admin-pass "${NEXTCLOUDPASSWORD}"
    sudo -u caddy php occ config:system:set \
        trusted_domains 0 \
        --value="${NEXTCLOUDDOMAIN}"
    sudo -u caddy php occ config:system:set \
        overwrite.cli.url --value="http://${NEXTCLOUDDOMAIN}"
    sudo -u caddy php occ config:system:set \
        --type=boolean \
        appstoreenabled --value=true
    sudo -u caddy php occ config:system:set \
        appstoreurl --value=https://www.orcy.net/ncapps/v1/
    sudo -u caddy php occ app:enable files_external
    popd
}

InstallRPM
ConfigureCaddy
InitNextcloud
