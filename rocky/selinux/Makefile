all: releases
	cd caddy && sh caddy.sh && mv noarch/* ../releases

releases:
	mkdir releases

install:
	rpm -ev caddy_selinux
	rpm -ivh releases/*.rpm

clean:
	find . -name "tmp" -type d -exec rm -rf {} \+
	find . -name "noarch" -type d -exec rm -rf {} \+
	find . -name "*.pp" -exec rm -rf {} \;
	find . -name "*.src.rpm" -exec rm -f {} \;
	find . -name ".build" -type f -exec rm -rf {} \;
