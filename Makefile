PREFIX ?= /usr/local
ROOT ?= $(shell pwd)

test:
	test/documentation-test

lint:
	docker run --rm -v ${ROOT}:/mnt koalaman/shellcheck src/semver
	docker run --rm -v ${ROOT}:/mnt koalaman/shellcheck test/documentation-test

install:
	install src/semver ${DESTDIR}${PREFIX}/bin

.PHONY: test install lint
