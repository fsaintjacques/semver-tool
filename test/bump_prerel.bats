#       "bats" test script for semver-tool.
#       Tests number bumping of pre-release part.
#
#       see: https://github.com/bats-core/bats-core
#       see: https://hub.docker.com/r/bats/bats
#
#       N.B. The script assumes that the bats intepreter is invoked from the
#            root directory of the semver-tool source tree.
#
#       examples:
#               run all .bats scripts in "test":
#                       cd $SEMVER_HOME ; bats test
#
#               run all .bats scripts in "test" using docker:
#                       docker run --rm -v "$(pwd):/mnt" -w /mnt bats/bats:latest test

SEMVER="src/semver"

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

