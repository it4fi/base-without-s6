# See also:
#
# https://linuxhint.com/install_configure_docker_ubuntu/
# https://phoenixnap.com/kb/install-docker-compose-on-ubuntu-20-04

SHELL=/bin/bash
CURRENT_UID=$(shell id -u)

PLATFORM=local
TAG=base:latest
USER2ADD=test_user2

.PHONY: all test build

all: test
	@echo; echo "  Prerequisites successful: $^"; echo

test: build
	@echo; echo "  Prerequisites successful: $^"; echo
	@sudo -E docker run -itv `pwd`/test:/opt base /opt/test.sh ${USER2ADD}
	@sudo -E docker run -it base bash

build:
	@echo "- CURRENT_UID ${CURRENT_UID}"
	@sudo -E docker build --build-arg CURRENT_UID=${CURRENT_UID} \
		. --platform ${PLATFORM} --tag ${TAG}
