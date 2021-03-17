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
