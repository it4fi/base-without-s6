# See also:
#
# https://linuxhint.com/install_configure_docker_ubuntu/
# https://phoenixnap.com/kb/install-docker-compose-on-ubuntu-20-04

PLATFORM=local
TAG=base:latest
USER=test_user2

.PHONY: all test build

all: test
	@echo; echo "  Prerequisites successful: $^"; echo

test: build
	@echo; echo "  Prerequisites successful: $^"; echo
	@sudo -E docker run -itv `pwd`/test:/opt base /opt/test.sh ${USER}
	@sudo -E docker run -it base bash

build:
	@sudo -E docker build . --platform ${PLATFORM} --tag ${TAG}
