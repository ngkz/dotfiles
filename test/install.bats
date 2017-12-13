#!/usr/bin/env bats
# vim: ft=sh

work="$BATS_TMPDIR/work"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
}

teardown() {
    rm -rf "$work"
}

@test "install --dry-run" {
    echo 'is_dry_run && echo yes || echo no' >"$work/test.df.sh"
    run "$install" --dry-run "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "yes" ]]

    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "no" ]]
}
