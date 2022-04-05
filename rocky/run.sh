#!/bin/sh
set -e

[ -d /usr/local/src/rpms ] || sh ./prepare.sh

[ -s /usr/bin/caddy ] || sh caddy/install.sh

[ -s /srv/www/nextcloud/index.php ] || sh nextcloud/install-php.sh && sh nextcloud/install-nextcloud.sh
