#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: "general.bats" for more information

SEMVER="src/semver"

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

@test "bad version in compare" {
	run $SEMVER compare 1.1.1-rc1+build2 1.1.1-rc1+
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
