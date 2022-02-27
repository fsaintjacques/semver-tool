#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: https://github.com/bats-core/bats-core
#	see: https://hub.docker.com/r/bats/bats
#
#	N.B. The script assumes that the bats intepreter is invoked from the
#	     root directory of the semver-tool source tree.
#
#	examples:
#		run all .bats scripts in "test":
#			cd $SEMVER_HOME ; bats test
#
#		run all .bats scripts in "test" using docker:
#			docker run --rm -v "$(pwd):/mnt" -w /mnt bats/bats:latest test
#
#	test organization:
#		The test files cover the misc/general tests plus files
#		for each sub-command:
#		-- general.bats (this file)
#		-- bump.bats
#		-- compare.bats
#		-- diff.bats
#		-- get.bats
#		-- validate.bats
#
#	Each file can be run independently.
#	Each file needs to define: SEMVER="src/semver"

SEMVER="src/semver"

@test "simple --help option" {
	run $SEMVER --help
	[ "${lines[0]}" = "Usage:" ]
}

@test "--help option with extra stuff" {
	run $SEMVER --help bump major 1.2.3
	[ "${lines[0]}" = "Usage:" ]
}

@test "simple --version option" {
	run $SEMVER --version
	[[ "${lines[0]}" == "semver:"* ]]
}

@test "no arguments" {
	run $SEMVER
	[ "$status" -eq 1 ]
}
