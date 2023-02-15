#	Mostly drives how 'semver' is tested.  Also has an 'install' target.
#	N.B. 'semver' does not need to be built: it's simply an executable script.

#	The default installation directory (see the 'install' target for more info)
PREFIX ?= /usr/local

#	The full path name of the source code repository.  Used for "bind mounts" in
#	Docker
SRC ?= $(shell pwd)

#	The current version of the project, taken from the source code
VERSION ?= $(shell cat ${SRC}/src/semver | grep 'PROG_VERSION=' | cut -d '"' -f 2)

#   The Docker Hub namespace of the project, defaulting to 'fsaintjacques'
VENDOR ?= fsaintjacques

#   The current date and time, in UTC, in ISO 8601 format
TODAY ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

#	The current commit hash
COMMIT ?= $(shell git rev-parse HEAD)

#	rule #1: don't hardcode; define it once in this file
include DEPENDENCIES

#	"build" builds the Docker image used for the project
build:
	docker build \
		--no-cache \
		--build-arg BUILD_VERSION="${VERSION}" \
		--build-arg BUILD_DATE="${TODAY}" \
		--build-arg SCHEMA_NAME=semver-tool \
		--build-arg SCHEMA_VENDOR="${VENDOR}" \
		--build-arg BUILD_VCS_REF="${COMMIT}" \
		--build-arg BUILD_VCS_URL="https://github.com/${VENDOR}/semver-tool" \
		-t "${VENDOR}/semver-tool:${VERSION}" \
		.

#	"push" pushes the Docker image to Docker Hub
push:
	echo "${DOCKER_PASSWORD}"" | docker login --username "${DOCKER_USERNAME}" --password-stdin
	docker push "${VENDOR}/semver-tool:${VERSION}"
	docker push "${VENDOR}/semver-tool:latest"

#	these definitions are common to local/developer and automated testing
lint_semver_args = --shell=bash src/semver
lint_doctest_args = --shell=bash test/documentation-test
test_semver_args = test
test_doctest_args = test/documentation-test

#	"semver" and "help" -- default target explains what's going on
semver:
	@echo Nothing to make: semver in src/semver is an executable script
	@echo Run \"make help\" for more details

help:	semver
	@echo
	@echo \"make test-stable\" runs all tests in well defined Docker environments
	@echo \"make test-local\" runs all tests assuming test tools are locally installed
	@echo
	@echo \"make install\" installs \'semver\' to ${DESTDIR}${PREFIX}/bin
	@echo 
	@echo See the Makefile and README for even more details

#	"test-stable" relies on well defined and stable test tools.
#	It is run by GitHub actions.
#	"test-stable" can be run locally as long as Docker is installed and up.
#	This might be a good idea before pushing to GitHub or generating a PR.
test-stable: lint unit-test doc-test 

#	"test-local" assumes that the test tools (bats, shellcheck, bash) are installed.
#	Unlike "test-stable", one is free to install any version of the tools and
#	by any method: useful for development and exploring new versions. "asdf" might
#	be the right way to set up your local dev. environment.
test-local: lint-local unit-test-local doc-test-local 


#	"lint" tests check shell scripts for dubious code
lint:
	docker run --rm -v "${SRC}:/semver-tool:ro" -w /semver-tool \
		${shellcheck_docker_image}:${shellcheck_image_tag} ${lint_semver_args}
	docker run --rm -v "${SRC}:/semver-tool:ro" -w /semver-tool \
		${shellcheck_docker_image}:${shellcheck_image_tag} ${lint_doctest_args}

#	the main functional/unit tests for 'semver'
unit-test:
	docker run --rm -v "${SRC}:/semver-tool:ro" -w /semver-tool \
		${bats_docker_image}:${bats_image_tag} ${test_semver_args}

#	tests that the README documentation conforms to 'semver' behaviour
doc-test:
	docker run --rm -v "${SRC}:/semver-tool:ro" -w /semver-tool \
		${bash_docker_image}:${bash_image_tag} ${test_doctest_args}


#	"lint" tests check shell scripts for dubious code
lint-local:
	shellcheck ${lint_semver_args}
	shellcheck ${lint_doctest_args}

#	the main functional/unit tests for 'semver'
unit-test-local:
	bats ${test_semver_args}

#	tests that the README documentation conforms to 'semver' behaviour
doc-test-local:
	bash ${test_doctest_args}

#
#	"install" copies the script to the desired installation location.  Note that
#	if 'DESTDIR' is not set (via, perhaps, the environment), only the 'PREFIX'
#	is used (defined above, but can be overridden).  Without 'DESTDIR',
#	the installation is to a global path (e.g. /usr/local)
install:
	install src/semver ${DESTDIR}${PREFIX}/bin

.PHONY: lint unit-test doc-test lint lint-local unit-test-local doc-test-local install semver help
