all: noarch
	cp noarch/* ../releases

noarch:
	sh nextcloud.sh

uninstall:
	rpm -ev nextcloud_selinux

install:
	rpm -ivh noarch/*.rpm

reinstall: uninstall install
