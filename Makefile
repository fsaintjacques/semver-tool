test: dummy-test
dummy-test:
	cd test; ./documentation-test

install: test
	install src/semver /usr/local/bin
