PREFIX ?= /usr/local
ROOT ?= $(shell pwd)

test: doc-test unit-test

doc-test:
	test/documentation-test

unit-test:
	docker run --rm -v "${ROOT}:/mnt" -w /mnt bats/bats:1.6.0 test

lint:
	docker run --rm -v ${ROOT}:/mnt koalaman/shellcheck --shell=bash src/semver
	docker run --rm -v ${ROOT}:/mnt koalaman/shellcheck --shell=bash test/documentation-test

install:
	install src/semver ${DESTDIR}${PREFIX}/bin

.PHONY: doc-test unit-test install lint
