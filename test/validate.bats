#	"bats" test script for semver 2.0.0 specification (https://semver.org/)
#
#	see: "general.bats" for more information

SEMVER="src/semver"

@test "missing arg in validate" {
	run $SEMVER validate 
	[ "$status" -eq 1 ]
}

@test "correct arg in validate" {
	run $SEMVER validate 1.2.2
	[ "$status" -eq 0 ]
}

@test "too many args in validate" {
	run $SEMVER validate 1.2.2 1.0.0
	[ "$status" -eq 1 ]
}

@test "invalid semver with major only" {
	result="$($SEMVER validate 1)"
	[ "$result" = "invalid" ]
}

@test "invalid semver with minor only" {
	result="$($SEMVER validate 1.1)"
	[ "$result" = "invalid" ]
}

@test "valid semver with major/minor/patch" {
	result="$($SEMVER validate 1.1.1)"
	[ "$result" = "valid" ]
}

@test "invalid semver with pre-release" {
	result="$($SEMVER validate 1.1.1-)"
	[ "$result" = "invalid" ]
}

@test "valid semver with pre-release" {
	result="$($SEMVER validate 1.1.1-1)"
	[ "$result" = "valid" ]
}

@test "invalid semver with build" {
	result="$($SEMVER validate 1.1.1+)"
	[ "$result" = "invalid" ]
}

@test "valid semver with build" {
	result="$($SEMVER validate 1.1.1+1)"
	[ "$result" = "valid" ]
}

@test "valid semver with pre-release and build" {
	result="$($SEMVER validate 1.1.1-1+1)"
	[ "$result" = "valid" ]
}
