#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: "general.bats" for more information

SEMVER="src/semver"

@test "diff versions (major)" {
	result="$($SEMVER diff 1.2.3 2.3.4)"
	[ "$result" = "major" ]
}

@test "diff versions (minor)" {
	result="$($SEMVER diff 1.2.3 1.3.4)"
	[ "$result" = "minor" ]
}

@test "diff versions (patch)" {
	result="$($SEMVER diff 1.2.3 1.2.4)"
	[ "$result" = "patch" ]
}

@test "diff versions (prerelease)" {
	result="$($SEMVER diff 1.2.3-alpha 1.2.3-beta)"
	[ "$result" = "prerelease" ]
}

@test "diff versions (equal)" {
	result="$($SEMVER diff 1.2.3 1.2.3)"
	[ "$result" = "" ]
}
