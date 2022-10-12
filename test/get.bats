#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: "general.bats" for more information

SEMVER="src/semver"

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

@test "get prerelease" {
	result="$($SEMVER get prerelease 0.2.1-rc1.-0+build-1234)"
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

@test "bad version in get minor" {
	run $SEMVER get minor 1.2.
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

#	A build-metadata version MAY be denoted by appending a hyphen and a series of dot
#	separated identifiers immediately following the patch version. Identifiers MUST
#	comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-]. Identifiers MUST NOT
#	be empty. Numeric identifiers MUST NOT include leading zeroes. Pre-release versions
#	have a lower precedence than the associated normal version. A pre-release version
#	indicates that the version is unstable and might not satisfy the intended
#	compatibility requirements as denoted by its associated normal version.
#	Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92.

@test "get valid pre-release parts (w/alpha)" {
	result="$($SEMVER get prerel 1.0.0-alpha)"
	[ "$result" = "alpha" ]
}

@test "get valid pre-release parts (alpha & numeric)" {
	result="$($SEMVER get prerel 1.0.0-alpha.1)"
	[ "$result" = "alpha.1" ]
}

@test "get valid pre-release parts (alpha w/zero & numeric)" {
	result="$($SEMVER get prerel 1.0.0-0alpha.1)"
	[ "$result" = "0alpha.1" ]
}

@test "get valid pre-release parts (numerics)" {
	result="$($SEMVER get prerel 1.0.0-0.3.7)"
	[ "$result" = "0.3.7" ]
}

@test "get valid pre-release parts (complex w/alpha)" {
	result="$($SEMVER get prerel 1.0.0-x.7.z.92)"
	[ "$result" = "x.7.z.92" ]
}

@test "get valid pre-release parts (w/hypen)" {
	result="$($SEMVER get prerel 1.0.0-x-.7.--z.92-)"
	[ "$result" = "x-.7.--z.92-" ]
}

@test "invalid character in pre-release: $" {
	run $SEMVER get prerel "1.0.0-x.7.z$.92"
	[ "$status" -eq 1 ]
}

@test "invalid character in pre-release: _" {
	run $SEMVER get prerel "1.0.0-x_.7.z.92"
	[ "$status" -eq 1 ]
}

@test "leading zero in pre-release" {
	run $SEMVER get prerel "1.0.0-x.7.z.092"
	[ "$status" -eq 1 ]
}

@test "two leading zeros in pre-release" {
	run $SEMVER get prerel "1.0.0-x.07.z.092"
	[ "$status" -eq 1 ]
}

@test "empty identifier in pre-release (embedded)" {
	run $SEMVER get prerel "1.0.0-x.7.z..92"
	[ "$status" -eq 1 ]
}

@test "empty identifier in pre-release (leading)" {
	run $SEMVER get prerel "1.0.0-.x.7.z.92"
	[ "$status" -eq 1 ]
}

@test "empty identifier in pre-release (trailing)" {
	run $SEMVER get prerel "1.0.0-x.7.z.92."
	[ "$status" -eq 1 ]
}

#	Build metadata MAY be denoted by appending a plus sign and a series of dot
#	separated identifiers immediately following the patch or pre-release version.
#	Identifiers MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-].
#	Identifiers MUST NOT be empty. Build metadata MUST be ignored when determining
#	version precedence. Thus two versions that differ only in the build metadata,
#	have the same precedence. Examples: 1.0.0-alpha+001, 1.0.0+20130313144700,
#	1.0.0-beta+exp.sha.5114f85.

@test "get valid build-metadata parts (numeric)" {
	result="$($SEMVER get build 1.0.0-alpha+001)"
	[ "$result" = "001" ]
}

@test "get valid build-metadata parts (numeric after patch)" {
	result="$($SEMVER get build 1.0.0+20130313144700)"
	[ "$result" = "20130313144700" ]
}

@test "get valid build-metadata parts (alpha & numeric)" {
	result="$($SEMVER get build 1.0.0-beta+exp.sha.5114f85)"
	[ "$result" = "exp.sha.5114f85" ]
}

@test "get valid build-metadata parts (alpha & numeric after patch)" {
	result="$($SEMVER get build 1.0.0+exp.sha.5114f85)"
	[ "$result" = "exp.sha.5114f85" ]
}

@test "get valid build-metadata parts (w/leading zero)" {
	result="$($SEMVER get build 1.0.0-x.7.z.92+02)"
	[ "$result" = "02" ]
}

@test "get valid build-metadata parts (w/leading hypen)" {
	result="$($SEMVER get build 1.0.0-x.7.z.92+-alpha-2)"
	[ "$result" = "-alpha-2" ]
}

@test "get valid build-metadata parts (w/trailing hypen)" {
	result="$($SEMVER get build 1.0.0-x.7.z.92+-alpha-2-)"
	[ "$result" = "-alpha-2-" ]
}

@test "invalid character in build-metadata: $" {
	run $SEMVER get build "1.0.0-x+7.z$.92"
	[ "$status" -eq 1 ]
}

@test "invalid character in build-metadata: _" {
	run $SEMVER get build "1.0.0-x+7.z.92._"
	[ "$status" -eq 1 ]
}

@test "invalid character in build-metadata after patch" {
	run $SEMVER get build "1.0.0+7.z$.92"
	[ "$status" -eq 1 ]
}

@test "empty identifier in build-metadata (embedded)" {
	run $SEMVER get build "1.0.0-x+7.z..92"
	[ "$status" -eq 1 ]
}

@test "empty identifier in build-metadata (leading)" {
	run $SEMVER get build "1.0.0+.x.7.z.92"
	[ "$status" -eq 1 ]
}

@test "empty identifier in build-metadata (trailing)" {
	run $SEMVER get build "1.0.0-x.7+z.92."
	[ "$status" -eq 1 ]
}
