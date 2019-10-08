#	"bats" test script for semver-tool. Mostly addresses the tools's API (command set).
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

SEMVER="src/semver"

@test "bump patch" {
	result="$($SEMVER bump patch 0.2.1)"
	[ "$result" = "0.2.2" ]
}

@test "bump minor" {
	result="$($SEMVER bump minor 0.2.1)"
	[ "$result" = "0.3.0" ]
}

@test "bump major" {
	result="$($SEMVER bump major 0.2.1)"
	[ "$result" = "1.0.0" ]
}

@test "bump major with leading 'v'" {
	result="$($SEMVER bump major v0.2.1)"
	[ "$result" = "1.0.0" ]
}

@test "bump major with leading 'V'" {
	result="$($SEMVER bump major V0.2.1)"
	[ "$result" = "1.0.0" ]
}

@test "bump to release (no-op)" {
	result="$($SEMVER bump release 0.2.1)"
	[ "$result" = "0.2.1" ]
}

@test "bump to release (strip pre-release)" {
	result="$($SEMVER bump release 0.2.1-rc1.0)"
	[ "$result" = "0.2.1" ]
}

@test "bump to release (strip pre-release and build)" {
	result="$($SEMVER bump release 0.2.1-rc1.0+build-1234)"
	[ "$result" = "0.2.1" ]
}

@test "bump prerel" {
	result="$($SEMVER bump prerel rc.1 0.2.1)"
	[ "$result" = "0.2.1-rc.1" ]
}

@test "bump prerel (replace and strip build metadata)" {
	result="$($SEMVER bump prerel rc.1 0.2.1-0.2+b13)"
	[ "$result" = "0.2.1-rc.1" ]
}

@test "bump prerel (strip build metadata)" {
	result="$($SEMVER bump prerel rc.1 0.2.1+b13)"
	[ "$result" = "0.2.1-rc.1" ]
}

@test "bump build (replace build metadata)" {
	result="$($SEMVER bump build b.1 0.2.1+b13)"
	[ "$result" = "0.2.1+b.1" ]
}

@test "bump build (preserve prerel, replace build metadata)" {
	result="$($SEMVER bump build b.1 0.2.1-rc12+b13)"
	[ "$result" = "0.2.1-rc12+b.1" ]
}

@test "compare released versions (less)" {
	result="$($SEMVER compare 0.2.1 0.2.2)"
	[ "$result" = "-1" ]
}

@test "compare released versions (equal)" {
	result="$($SEMVER compare 1.2.1 1.2.1)"
	[ "$result" = "0" ]
}

@test "compare released versions (greater)" {
	result="$($SEMVER compare 0.3.1 0.2.5)"
	[ "$result" = "1" ]
}

@test "get major" {
	result="$($SEMVER get major 0.2.1-rc1.0+build-1234)"
	[ "$result" = "0" ]
}

@test "get minor" {
	result="$($SEMVER get minor 0.2.1-rc1.0+build-1234)"
	[ "$result" = "2" ]
}

@test "get patch" {
	result="$($SEMVER get patch 0.2.1-rc1.0+build-1234)"
	[ "$result" = "1" ]
}

@test "get prerel" {
	result="$($SEMVER get prerel 0.2.1-rc1.-0+build-1234)"
	[ "$result" = "rc1.-0" ]
}

@test "get build" {
	result="$($SEMVER get build 0.2.1-rc1.0+build-0234)"
	[ "$result" = "build-0234" ]
}

@test "get release" {
	result="$($SEMVER get release 0.2.1-rc1.0+build-0234)"
	[ "$result" = "0.2.1" ]
}

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

@test "extra arguments" {
	run $SEMVER bump minor 9.8.7 0.1.2
	[ "$status" -eq 1 ]
}

@test "bad version in bump patch" {
	run $SEMVER bump patch bogus
	[ "$status" -eq 1 ]
}

@test "bad version in get minor" {
	run $SEMVER get minor 1.2.
	[ "$status" -eq 1 ]
}

@test "bad version in compare" {
	run $SEMVER compare 1.1.1-rc1+build2 1.1.1-rc1+
	[ "$status" -eq 1 ]
}

@test "missing prerel in get patch" {
	run $SEMVER get patch 1.2.4-
	[ "$status" -eq 1 ]
}

@test "missing build in get build" {
	run $SEMVER get build 1.2.4+
	[ "$status" -eq 1 ]
}

