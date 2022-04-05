all: releases releases/caddy*.rpm releases/nextcloud*.rpm

releases:
	mkdir releases

releases/caddy*.rpm:
	$(MAKE) -C caddy all

releases/nextcloud*.rpm:
	$(MAKE) -C nextcloud all

deploy:
	cp releases/* ../packages

clean:
	find . -name "tmp" -type d -exec rm -rf {} \+
	find . -name "noarch" -type d -exec rm -rf {} \+
	find . -name "*.pp" -exec rm -rf {} \;
	find . -name "*.src.rpm" -exec rm -f {} \;
	find . -name ".build" -type f -exec rm -rf {} \;
	rm -rf releases
