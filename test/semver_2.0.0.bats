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

SEMVER="src/semver"

#	A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative
#	integers, and MUST NOT contain leading zeroes. X is the major version, Y is the minor
#	version, and Z is the patch version. Each element MUST increase numerically.
#	For instance: 1.9.0 -> 1.10.0 -> 1.11.0.	

@test "normal version" {
	result="$($SEMVER bump release 1.9.0)"
	[ "$result" = "1.9.0" ]
}

@test "leading zeros (major)" {
	run $SEMVER bump release 01.9.1
	[ "$status" -eq 1 ]
}

@test "leading zeros (minor)" {
	run $SEMVER bump release 1.09.1
	[ "$status" -eq 1 ]
}

@test "leading zeros (patch)" {
	run $SEMVER bump release 1.9.01
	[ "$status" -eq 1 ]
}

@test "double zeros (patch)" {
	run $SEMVER bump release 1.9.00
	[ "$status" -eq 1 ]
}

@test "invalid character (minor)" {
	run $SEMVER bump release 1.9a.0
	[ "$status" -eq 1 ]
}

@test "invalid character (major)" {
	run $SEMVER bump release -1.9.0
	[ "$status" -eq 1 ]
}

#	Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards compatible
#	functionality is introduced to the public API. It MUST be incremented if any public
#	API functionality is marked as deprecated. It MAY be incremented if substantial
#	new functionality or improvements are introduced within the private code. It MAY
#	include patch level changes. Patch version MUST be reset to 0 when minor version
#	is incremented.

@test "bump minor and zero patch" {
	result="$($SEMVER bump minor 1.9.1)"
	[ "$result" = "1.10.0" ]
}

#	Major version X (X.y.z | X > 0) MUST be incremented if any backwards incompatible
#	changes are introduced to the public API. It MAY also include minor and patch
#	level changes. Patch and minor version MUST be reset to 0 when major version
#	is incremented.

@test "bump major and zero minor, patch" {
	result="$($SEMVER bump major 1.9.1)"
	[ "$result" = "2.0.0" ]
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

@test "bump leading zero in pre-release" {
	run $SEMVER bump prerel "x.7.z.092" "1.0.0"
	[ "$status" -eq 1 ]
}

@test "bump invalid character in pre-release" {
	run $SEMVER bump prerel "x.=.z.92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in pre-release (embedded)" {
	run $SEMVER bump prerel "x.7.z..92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in pre-release (leading)" {
	run $SEMVER bump prerel ".x.7.z.92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in pre-release (trailing)" {
	run $SEMVER bump prerel "x.7.z.92." "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump pre-release to invalid version" {
	run $SEMVER bump prerel "x.7.z.92" "1.00.0" 
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

@test "bump invalid character in build-metadata: $" {
	run $SEMVER bump build "7.z$.92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump invalid character in build-metadata: _" {
	run $SEMVER bump build "7.z.92._" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in build-metadata (embedded)" {
	run $SEMVER bump build "7.z..92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in build-metadata (leading)" {
	run $SEMVER bump build ".x.7.z.92" "1.0.0" 
	[ "$status" -eq 1 ]
}

@test "bump empty identifier in build-metadata (trailing)" {
	run $SEMVER bump build "z.92." "1.0.0" 
	[ "$status" -eq 1 ]
}

#	Precedence refers to how versions are compared to each other when ordered.
#	Precedence MUST be calculated by separating the version into major, minor,
#	patch and pre-release identifiers in that order (Build metadata does not figure
#	into precedence). Precedence is determined by the first difference when comparing
#	each of these identifiers from left to right as follows: Major, minor, and patch
#	versions are always compared numerically. Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1.
#	When major, minor, and patch are equal, a pre-release version has lower precedence
#	than a normal version. Example: 1.0.0-alpha < 1.0.0. Precedence for two pre-release
#	versions with the same major, minor, and patch version MUST be determined by
#	comparing each dot separated identifier from left to right until a difference is
#	found as follows: identifiers consisting of only digits are compared numerically
#	and identifiers with letters or hyphens are compared lexically in ASCII sort order.
#	Numeric identifiers always have lower precedence than non-numeric identifiers.
#	A larger set of pre-release fields has a higher precedence than a smaller set,
#	if all of the preceding identifiers are equal. Example: 1.0.0-alpha < 1.0.0-alpha.1
#	< 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.

@test "compare versions (1)" {
	result="$($SEMVER compare 1.0.0-alpha 1.0.0-alpha.1)"
	[ "$result" = "-1" ]
}

@test "compare versions (2)" {
	result="$($SEMVER compare 1.0.0-alpha.1 1.0.0-alpha.beta)"
	[ "$result" = "-1" ]
}

@test "compare versions (3)" {
	result="$($SEMVER compare 1.0.0-alpha.beta 1.0.0-beta)"
	[ "$result" = "-1" ]
}

@test "compare versions (4)" {
	result="$($SEMVER compare 1.0.0-beta 1.0.0-beta.2)"
	[ "$result" = "-1" ]
}

@test "compare versions (5)" {
	result="$($SEMVER compare 1.0.0-beta.2 1.0.0-beta.11)"
	[ "$result" = "-1" ]
}

@test "compare versions (6)" {
	result="$($SEMVER compare 1.0.0-beta.11 1.0.0-rc.1)"
	[ "$result" = "-1" ]
}

@test "compare versions (7)" {
    result="$($SEMVER compare 1.0.0-rc.1 1.0.0)"
	[ "$result" = "-1" ]
}

@test "compare versions (greater)" {
	result="$($SEMVER compare 1.0.0 1.0.0-rc.1)"
	[ "$result" = "1" ]
}

@test "compare versions (numeric vs alpha)" {
	result="$($SEMVER compare 1.0.0-alpha 1.0.0-666)"
	[ "$result" = "1" ]
}

@test "compare versions (equal)" {
	result="$($SEMVER compare 1.0.0 1.0.0)"
	[ "$result" = "0" ]
}

@test "compare versions (ignore pre-release)" {
	result="$($SEMVER compare 1.0.1 1.0.0-rc1)"
	[ "$result" = "1" ]
}

@test "compare versions (alpha pre-release ids)" {
	result="$($SEMVER compare 1.0.0-beta2 1.0.0-beta11)"
	[ "$result" = "1" ]
}

@test "compare versions (numeric pre-release ids)" {
	result="$($SEMVER compare 1.0.0-2 1.0.0-11)"
	[ "$result" = "-1" ]
}

@test "compare versions (less, ignore build metadata)" {
	result="$($SEMVER compare 1.0.0-beta1+a 1.0.0-beta2+z)"
	[ "$result" = "-1" ]
}

@test "compare versions (equal, ignore build metadata)" {
	result="$($SEMVER compare 1.0.0-beta2+x 1.0.0-beta2+y)"
	[ "$result" = "0" ]
}

@test "compare versions (greater, ignore build metadata)" {
	result="$($SEMVER compare 1.0.0-12.beta2+x 1.0.0-11.beta2+y)"
	[ "$result" = "1" ]
}

@test "compare versions (ignore build metadata w/no pre-release)" {
	result="$($SEMVER compare 1.0.0+x 1.0.0+y)"
	[ "$result" = "0" ]
}

