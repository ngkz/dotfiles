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

@test "_define: check number of arguments" {
    cat <<'EOH' >"$work/test.df.sh"
_define action impl extra
EOH
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ $output = 'Wrong number of arguments' ]]

    cat <<'EOH' >"$work/test.df.sh"
_define action impl
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
}

@test "_define: define action" {
    cat <<'EOH' >"$work/test.df.sh"
impl_ok() {
    return 0
}

_define action_ok impl_ok

impl_changed() {
    _flag_changed
    return 0
}

_define action_changed impl_changed

impl_failed() {
    return 1
}

_define action_failed impl_failed

action_ok
action_changed
is_changed && echo "changed flag is set"
action_ok
is_changed || echo "changed flag is reset"
action_failed
echo "this won't get executed"
EOH
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ ${#lines[@]} -eq 6 ]]
    [[ ${lines[0]} = '[   OK   ] test: action_ok ' ]]
    [[ ${lines[1]} = '[CHANGED ] test: action_changed ' ]]
    [[ ${lines[2]} = 'changed flag is set' ]]
    [[ ${lines[3]} = '[   OK   ] test: action_ok ' ]]
    [[ ${lines[4]} = 'changed flag is reset' ]]
    [[ ${lines[5]} = '[ FAILED ] test: action_failed ' ]]
}
