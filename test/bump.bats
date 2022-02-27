#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: "general.bats" for more information

SEMVER="src/semver"

#	simple bump tests

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

@test "extra arguments" {
	run $SEMVER bump minor 9.8.7 0.1.2
	[ "$status" -eq 1 ]
}

@test "bad version in bump patch" {
	run $SEMVER bump patch bogus
	[ "$status" -eq 1 ]
}

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

#	Semantic versioning semantics specify that the minor version Y (x.Y.z | x > 0)
#	MUST be incremented if new, backwards compatible
#	functionality is introduced to the public API. It MUST be incremented if any public
#	API functionality is marked as deprecated. It MAY be incremented if substantial
#	new functionality or improvements are introduced within the private code. It MAY
#	include patch level changes. Patch version MUST be reset to 0 when minor version
#	is incremented.

@test "bump minor and zero patch" {
	result="$($SEMVER bump minor 1.9.1)"
	[ "$result" = "1.10.0" ]
}

#	Semantic versioning semantics specify that the major version X (X.y.z | X > 0)
#	MUST be incremented if any backwards incompatible
#	changes are introduced to the public API. It MAY also include minor and patch
#	level changes. Patch and minor version MUST be reset to 0 when major version
#	is incremented.

@test "bump major and zero minor, patch" {
	result="$($SEMVER bump major 1.9.1)"
	[ "$result" = "2.0.0" ]
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

@test "bump pre-release to invalid version" {
	run $SEMVER bump prerel "x.7.z.92" "1.00.0"
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

#       bump prerel tests covering numerical increments

#       sanity tests: should pass in all versions

@test "basic bump prerel (set)" {
        result="$($SEMVER bump prerel rc.1 0.2.1)"
        [ "$result" = "0.2.1-rc.1" ]
}

@test "basic bump prerel (replace and strip pre-release and build metadata)" {
        result="$($SEMVER bump prerel rc.1 0.2.1-0.2+b13)"
        [ "$result" = "0.2.1-rc.1" ]
}

@test "basic bump prerel (strip build metadata)" {
        result="$($SEMVER bump prerel rc.1 0.2.1+b13)"
        [ "$result" = "0.2.1-rc.1" ]
}

#       test bump pre-release using the explicit prefix numbering scheme

@test "bump prerel (add numeric id)" {
        result="$($SEMVER bump prerel . 0.2.1)"
        [ "$result" = "0.2.1-1" ]
}

@test "bump prerel (replace with numeric id)" {
        result="$($SEMVER bump prerel . 0.2.1-alpha)"
        [ "$result" = "0.2.1-1" ]
}

@test "bump prerel (inc numeric id)" {
        result="$($SEMVER bump prerel . 0.2.1-1)"
        [ "$result" = "0.2.1-2" ]
}

@test "bump prerel (add new pre-release part)" {
        result="$($SEMVER bump prerel rc. 0.2.1)"
        [ "$result" = "0.2.1-rc1" ]
}

@test "bump prerel (add new pre-release part with separated numeric id)" {
        result="$($SEMVER bump prerel rc.. 0.2.1)"
        [ "$result" = "0.2.1-rc.1" ]
}

@test "bump prerel (add numeric id to existing pre-release, similar prefix)" {
        result="$($SEMVER bump prerel rc.v. 0.2.1-rc.2)"
        [ "$result" = "0.2.1-rc.v1" ]
}

@test "bump prerel (add numeric id to existing pre-release, similar trailing id)" {
        result="$($SEMVER bump prerel rc.3. 0.2.1-rc.3)"
        [ "$result" = "0.2.1-rc.31" ]
}

@test "bump prerel (add numeric id to existing pre-release, similar trailing id - with dot)" {
        result="$($SEMVER bump prerel rc.3.. 0.2.1-rc.3)"
        [ "$result" = "0.2.1-rc.3.1" ]
}

@test "bump prerel (add numeric id to existing pre-release)" {
        result="$($SEMVER bump prerel rc. 0.2.1-rc)"
        [ "$result" = "0.2.1-rc1" ]
}

@test "bump prerel (replace with new pre-release part)" {
        result="$($SEMVER bump prerel rc. 0.2.1-alpha)"
        [ "$result" = "0.2.1-rc1" ]
}

@test "bump prerel (inc numeric id in pre-release part)" {
        result="$($SEMVER bump prerel rc. 0.2.1-rc1)"
        [ "$result" = "0.2.1-rc2" ]
}

@test "bump prerel (inc numeric id in pre-release part with dot)" {
        result="$($SEMVER bump prerel rc.. 0.2.1-rc.1)"
        [ "$result" = "0.2.1-rc.2" ]
}

@test "bump prerel (inc numeric id in pre-release part, multiple ids)" {
        result="$($SEMVER bump prerel v6.rc. 0.2.1-v6.rc1)"
        [ "$result" = "0.2.1-v6.rc2" ]
}

@test "bump prerel (inc numeric id in pre-release part with dot, multiple ids)" {
        result="$($SEMVER bump prerel 4.rc.. 0.2.1-4.rc.1)"
        [ "$result" = "0.2.1-4.rc.2" ]
}

#       error checking tests, explicit prefix

@test "bump prerel (inc numeric id in pre-release part, bad pre-release arg)" {
        run $SEMVER bump prerel .rc. 0.2.1-rc.1
        [ "$status" -eq 1 ]
}

@test "bump prerel (inc numeric id in pre-release part, bad version)" {
        run $SEMVER bump prerel rc. 0.2.1-.rc.1
        [ "$status" -eq 1 ]
}

@test "bump prerel (inc numeric id in pre-release part, 2-dot pre-release arg)" {
        run $SEMVER bump prerel .. 0.2.1-rc.1
        [ "$status" -eq 1 ]
}

@test "bump prerel (add numeric id in pre-release part, 2-dot pre-release arg)" {
        run $SEMVER bump prerel .. 0.2.1
        [ "$status" -eq 1 ]
}

#       test bump pre-release using the implicit numbering scheme

@test "bump prerel (inc numeric id in pre-release part, no-arg)" {
        result="$($SEMVER bump prerel 0.2.1-rc.1)"
        [ "$result" = "0.2.1-rc.2" ]
}

@test "bump prerel (add numeric id, no-arg)" {
        result="$($SEMVER bump prerel 0.2.1)"
        [ "$result" = "0.2.1-1" ]
}

@test "bump prerel (append numeric id to pre-release part, no-arg)" {
        result="$($SEMVER bump prerel 0.2.1-alpha)"
        [ "$result" = "0.2.1-alpha1" ]
}

@test "bump prerel (inc numeric id, no-arg)" {
        result="$($SEMVER bump prerel 0.2.1-1)"
        [ "$result" = "0.2.1-2" ]
}

#       error checking tests, implicit prefix

@test "bump prerel (add numeric id in pre-release part, bad version)" {
        run $SEMVER bump prerel 0.2.1-rc.
        [ "$status" -eq 1 ]
}
