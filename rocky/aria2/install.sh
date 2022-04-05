#!/bin/sh
# Aria2 download files to /srv/aria2/downloads
# /srv/aria2/downloads should be httpd_exec_t managable

InstallAria2 () {
    dnf install -y aria2
}
