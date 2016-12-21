test:
	test/documentation-test

install:
	install src/semver /usr/local/bin

.PHONY: test install
