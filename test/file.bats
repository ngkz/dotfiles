#!/usr/bin/env bats
# vim: ft=sh

work="$BATS_TMPDIR/file"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
}

teardown() {
    rm -rf "$work"
}

@test "file: getopt error" {
    echo "file --invalid-option src dest" >"$work/test.df.sh"
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ $output =~ "file: unrecognized option '--invalid-option'" ]]
}

@test "file: wrong number of arguments" {
    echo "file src" >"$work/test.df.sh"
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ ${#lines[@]} -eq 2 ]]
    [[ ${lines[1]} = "Wrong number of arguments" ]]
}

@test "file: check owner if --owner is passed" {
    touch "$work/src" "$work/dest"
    echo "file --owner=nobody src dest" >"$work/test.df.sh"
    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different owner (current: root, desired: nobody)' ]]
    [[ ${lines[2]} =~ 'Fix inconsistency?' ]]
}

@test "file: check group if --group is passed" {
    touch "$work/src" "$work/dest"
    echo "file --group=nogroup src dest" >"$work/test.df.sh"
    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different group (current: root, desired: nogroup)' ]]
    [[ ${lines[2]} =~ 'Fix inconsistency?' ]]
}

@test "file: check mode if --mode is passed" {
    touch "$work/src" "$work/dest"
    echo "file --mode=7777 src dest" >"$work/test.df.sh"
    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different mode (current: 0644, desired: 7777)' ]]
    [[ ${lines[2]} =~ 'Fix inconsistency?' ]]
}

@test "file: compare file content" {
    echo foo > "$work/src"
    echo bar > "$work/dest"
    echo "file src dest" >"$work/test.df.sh"
    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different file content' ]]
    [[ ${lines[2]} =~ 'Fix inconsistency?' ]]
}
