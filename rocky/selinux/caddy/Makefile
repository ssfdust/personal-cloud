objects := $(patsubst %.sh,%.rpm,$(wildcard ../releases/caddy*.rpm))

all: noarch
	cp noarch/* ../releases

noarch:
	sh caddy.sh
